#!/bin/sh

### CONFIGURATION ###

FLAKEDIR='@flake@'
HOSTNAME='@host@'
DISK='@disk@'
BOOT_LABEL='@boot@'
MAIN_LABEL='@main@'
SWAP_LABEL='@swap@'
ZFS_NIX='@nix@'
ZFS_HOME='@home@'
ZFS_HARDSTATE='@hardstate@'
ZFS_SOFTSTATE='@softstate@'
SWAP_SIZE='@swapsize@'

### HELPER FUNCTIONS ###

print_usage() {
    # Print script usage

    cat <<EOF
Usage: $0 [-k KEYFILE]
Install NixOS on a host.

    -k, --key               path to the age key file (if not specified, taken from \$SOPS_AGE_KEY_FILE)
EOF
}

### PARSE ARGUMENTS ###

keyfile="${SOPS_AGE_KEY_FILE:-${XDG_CONFIG_HOME:-$HOME/.config}/sops/age/keys.txt}}"
unparsed=''

while [ -n "${1:-}" ]; do
    case "$1" in
    -k | --key)
        shift
        keyfile="$1"
        ;;
    -h | --help)
        print_usage >&2
        exit
        ;;
    --)
        shift
        unparsed="$unparsed $*"
        break
        ;;
    *) unparsed="$unparsed $1" ;;
    esac
    shift
done

# shellcheck disable=SC2086
set -- $unparsed

### CLEANUP ###

echo "Cleaning up old state"

# remove old age key if exists
rm -f "/mnt/$ZFS_HARDSTATE/sops/age/keys.txt"

# unmount everything
mountpoint -q /mnt && umount -R /mnt

# disable swap
swapoff "/dev/disk/by-partlabel/$SWAP_LABEL" 2>/dev/null || true

# destroy zfs pool
zpool list -H -o name | grep -q "$MAIN_LABEL" && zpool destroy -f "$MAIN_LABEL"

### PARTITIONING ###

echo "Partitioning disk $DISK"

# partition the disk
# use GPT to store partition metadata
# boot partition at the beginning
# swap partition at the end
# and the rest is for the main partition
if ! parted --script --align optimal "$DISK" -- \
    mklabel gpt \
    mkpart "$BOOT_LABEL" fat32 1MB 512MB \
    set 1 boot on \
    set 1 esp on \
    mkpart "$MAIN_LABEL" 512MB "-$SWAP_SIZE" \
    mkpart "$SWAP_LABEL" linux-swap "-$SWAP_SIZE" 100%; then
    echo "Partitioning failed" >&2
    exit 1
fi

# force udev to reread partition table
udevadm trigger

printf '%s' "Waiting for partitions to appear..."
while [ ! -e "/dev/disk/by-partlabel/$MAIN_LABEL" ] ||
    [ ! -e "/dev/disk/by-partlabel/$SWAP_LABEL" ]; do
    sleep 1
    printf '%s' '.'
done
echo

echo "Partitioning complete"

### FORMATTING ###

# format the partitions with appropriate filesystems
# note that referring to devices by by-partlabel works only when using GPT

echo "Formatting /dev/disk/by-partlabel/$BOOT_LABEL with FAT32"

# fat32 for the boot partition
if ! mkfs.fat -c -F 32 -n "$BOOT_LABEL" "/dev/disk/by-partlabel/$BOOT_LABEL"; then
    echo "Formatting boot partition failed" >&2
    exit 2
fi

echo "Creating ZFS pool $MAIN_LABEL on /dev/disk/by-partlabel/$MAIN_LABEL"

# setup main partition with zfs
if ! zpool create -f \
    -o autoexpand=on \
    -o autoreplace=on \
    -o autotrim=on \
    -o 'comment=main pool' \
    -O aclinherit=passthrough \
    -O aclmode=passthrough \
    -O acltype=posix \
    -O atime=off \
    -O canmount=noauto \
    -O compression=off \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    "$MAIN_LABEL" "/dev/disk/by-partlabel/$MAIN_LABEL"; then
    echo "Creating ZFS pool failed" >&2
    exit 3
fi

echo "Creating ZFS datasets"

if ! zfs create -o compression=on "$MAIN_LABEL/$ZFS_NIX" ||
    ! zfs create -o compression=on "$MAIN_LABEL/$ZFS_HOME" ||
    ! zfs create -o compression=on "$MAIN_LABEL/$ZFS_HARDSTATE" ||
    ! zfs create -o compression=on "$MAIN_LABEL/$ZFS_SOFTSTATE"; then
    echo "Creating ZFS datasets failed" >&2
    exit 4
fi

echo "Formatting /dev/disk/by-partlabel/$SWAP_LABEL as swap"

# swap is just swap
if ! mkswap -c -L "$SWAP_LABEL" "/dev/disk/by-partlabel/$SWAP_LABEL"; then
    echo "Formatting swap partition failed" >&2
    exit 5
fi

# force udev to reread filesystems
udevadm trigger

printf '%s' "Waiting for filesystems to appear..."
while [ ! -e "/dev/disk/by-label/$BOOT_LABEL" ] ||
    [ ! -e "/dev/disk/by-label/$MAIN_LABEL" ] ||
    [ ! -e "/dev/disk/by-label/$SWAP_LABEL" ]; do
    sleep 1
    printf '%s' '.'
done
echo

echo "Formatting complete"

### PREPARATION ###

echo "Enabling swap"

# enable swap already so installation can use more memory
if ! swapon "/dev/disk/by-partlabel/$SWAP_LABEL"; then
    echo "Enabling swap failed" >&2
    exit 6
fi

echo "Mounting filesystems"

# mount everything
if ! mount -t tmpfs -o mode=755 none /mnt ||
    ! mkdir -p "/mnt/boot" "/mnt/nix" "/mnt/home" "/mnt/$ZFS_HARDSTATE" "/mnt/$ZFS_SOFTSTATE" ||
    ! mount -t vfat "/dev/disk/by-label/$BOOT_LABEL" "/mnt/boot" ||
    ! mount -t zfs -o zfsutil "$MAIN_LABEL/$ZFS_NIX" "/mnt/nix" ||
    ! mount -t zfs -o zfsutil "$MAIN_LABEL/$ZFS_HARDSTATE" "/mnt/$ZFS_HARDSTATE" ||
    ! mount -t zfs -o zfsutil "$MAIN_LABEL/$ZFS_SOFTSTATE" "/mnt/$ZFS_SOFTSTATE"; then
    echo "Mounting filesystems failed" >&2
    exit 7
fi

echo "Creating necessary directories"

if ! mkdir -p \
    "/mnt/$ZFS_SOFTSTATE/etc/NetworkManager/system-connections" \
    "/mnt/$ZFS_SOFTSTATE/var/cache" \
    "/mnt/$ZFS_SOFTSTATE/var/games" \
    "/mnt/$ZFS_SOFTSTATE/var/lib" \
    "/mnt/$ZFS_SOFTSTATE/var/log" \
    "/mnt/$ZFS_SOFTSTATE/var/tmp" \
    ; then
    echo "Creating directories failed" >&2
    exit 8
fi

echo "Copying age keys"

# copy age keys
if ! mkdir -p "/mnt/$ZFS_HARDSTATE/sops/age" ||
    ! cp "$keyfile" "/mnt/$ZFS_HARDSTATE/sops/age/keys.txt"; then
    echo "Copying age keys failed" >&2
    exit 8
fi

### INSTALLATION ###

echo "Installing NixOS"

# install
nixos-install --no-root-passwd --flake "$FLAKEDIR#$HOSTNAME" "$@"
