#!/bin/sh

### CONFIGURATION ###

# Don't try to make the script self-contained
# Just assume some binaries are already available
# First, this reduces the size down
# Second, some things need to be compatible with the host system

BOOT='@boot@'
DISK='@disk@'
FLAKEDIR='@flake@'
GREP='@grep@'
HARDSTATE='@hardstate@'
HOME='@home@'
HOSTNAME='@host@'
MAIN='@main@'
MKFSFAT='@mkfsfat@'
NIX='@nix@'
NIXOSINSTALL='@nixosinstall@'
PARTED='@parted@'
SOFTSTATE='@softstate@'
SWAP='@swap@'
SWAP_SIZE='@swapSize@'
ZFS_PACKAGE='@zfsPackage@'

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

keyfile="${SOPS_AGE_KEY_FILE:-${XDG_CONFIG_HOME:-${HOME}/.config}/sops/age/keys.txt}}"
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
		unparsed="${unparsed} $*"
		break
		;;
	*) unparsed="${unparsed} $1" ;;
	esac
	shift
done

# shellcheck disable=SC2086
set -- ${unparsed}

### CLEANUP ###

printf '%s\n' 'Cleaning up old state'

# remove old age key if exists
rm --force "/mnt/${HARDSTATE}/sops/age/keys.txt"

# unmount everything
mountpoint --quiet /mnt/ && umount --recursive /mnt/

# disable swap
swapoff "/dev/disk/by-partlabel/${SWAP}" 2>/dev/null || true

# destroy zfs pool
"${ZFS_PACKAGE}/bin/zpool" list -H -o name | ${GREP} --quiet "${MAIN}" && "${ZFS_PACKAGE}/bin/zpool" destroy -f "${MAIN}"

### PREPARATION ###

# install ZFS udev rules
mkdir --parents /etc/udev/rules.d/
cp "${ZFS_PACKAGE}"/lib/udev/rules.d/*.rules /etc/udev/rules.d/
udevadm control --reload-rules

### PARTITIONING ###

printf '%s\n' "Partitioning disk ${DISK}"

# partition the disk
# use GPT to store partition metadata
# boot partition at the beginning
# swap partition at the end
# and the rest is for the main partition
if ! ${PARTED} --script --align optimal "${DISK}" -- \
	mklabel gpt \
	mkpart "${BOOT}" fat32 1MB 512MB \
	set 1 boot on \
	set 1 esp on \
	mkpart "${MAIN}" 512MB "-${SWAP_SIZE}" \
	mkpart "${SWAP}" linux-swap "-${SWAP_SIZE}" 100%; then
	printf '%s\n' 'Partitioning failed' >&2
	exit 1
fi

# force udev to reread partition table
udevadm trigger

printf '%s' 'Waiting for partitions to appear...'
while [ ! -e "/dev/disk/by-partlabel/${BOOT}" ] ||
	[ ! -e "/dev/disk/by-partlabel/${MAIN}" ] ||
	[ ! -e "/dev/disk/by-partlabel/${SWAP}" ]; do
	sleep 1
	printf '%s' '.'
done
printf '\n'

printf '%s\n' 'Partitioning complete'

### FORMATTING ###

# format the partitions with appropriate filesystems
# note that referring to devices by by-partlabel works only when using GPT

printf '%s\n' "Formatting /dev/disk/by-partlabel/${BOOT} with FAT32"

# fat32 for the boot partition
if ! ${MKFSFAT} -c -F 32 -n "${BOOT}" "/dev/disk/by-partlabel/${BOOT}"; then
	printf '%s\n' 'Formatting boot partition failed' >&2
	exit 2
fi

printf '%s\n' "Creating ZFS pool ${MAIN} on /dev/disk/by-partlabel/${MAIN}"

# setup main partition with zfs
if ! "${ZFS_PACKAGE}/bin/zpool" create -f \
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
	"${MAIN}" "/dev/disk/by-partlabel/${MAIN}"; then
	printf '%s\n' 'Creating ZFS pool failed' >&2
	exit 3
fi

printf '%s\n' 'Creating ZFS datasets'

if ! "${ZFS_PACKAGE}/bin/zfs" create -o compression=on "${MAIN}/${HARDSTATE}" ||
	! "${ZFS_PACKAGE}/bin/zfs" create -o compression=on "${MAIN}/${HOME}" ||
	! "${ZFS_PACKAGE}/bin/zfs" create -o compression=on "${MAIN}/${NIX}" ||
	! "${ZFS_PACKAGE}/bin/zfs" create -o compression=on "${MAIN}/${SOFTSTATE}"; then
	printf '%s\n' 'Creating ZFS datasets failed' >&2
	exit 4
fi

printf '%s\n' "Formatting /dev/disk/by-partlabel/${SWAP} as swap"

# swap is just swap
if ! mkswap -c -L "${SWAP}" "/dev/disk/by-partlabel/${SWAP}"; then
	printf '%s\n' 'Formatting swap partition failed' >&2
	exit 7
fi

# force udev to reread filesystems
udevadm trigger

printf '%s' 'Waiting for filesystems to appear...'
while [ ! -e "/dev/disk/by-label/${BOOT}" ] ||
	[ ! -e "/dev/disk/by-label/${MAIN}" ] ||
	[ ! -e "/dev/disk/by-label/${SWAP}" ]; do
	sleep 1
	printf '%s' '.'
done
printf '\n'

printf '%s\n' 'Formatting complete'

### PREPARATION ###

printf '%s\n' 'Enabling swap'

# enable swap already so installation can use more memory
if ! swapon "/dev/disk/by-partlabel/${SWAP}"; then
	printf '%s\n' 'Enabling swap failed' >&2
	exit 8
fi

printf '%s\n' 'Mounting filesystems'

# mount everything
if ! mount --types tmpfs --options mode=755 none /mnt/ ||
	! mkdir --parents /mnt/boot/ /mnt/home/ /mnt/nix/ "/mnt/${HARDSTATE}/" "/mnt/${SOFTSTATE}/" ||
	! mount --types vfat "/dev/disk/by-label/${BOOT}" /mnt/boot/ ||
	! mount --types zfs --options zfsutil "${MAIN}/${HOME}" /mnt/home/ ||
	! mount --types zfs --options zfsutil "${MAIN}/${NIX}" /mnt/nix/ ||
	! mount --types zfs --options zfsutil "${MAIN}/${HARDSTATE}" "/mnt/${HARDSTATE}/" ||
	! mount --types zfs --options zfsutil "${MAIN}/${SOFTSTATE}" "/mnt/${SOFTSTATE}/"; then
	printf '%s\n' 'Mounting filesystems failed' >&2
	exit 9
fi

printf '%s\n' 'Copying age keys'

# copy age keys
if ! mkdir --parents "/mnt/${HARDSTATE}/sops/age/" ||
	! cp "${keyfile}" "/mnt/${HARDSTATE}/sops/age/keys.txt"; then
	printf '%s\n' 'Copying age keys failed' >&2
	exit 10
fi

### INSTALLATION ###

printf '%s\n' 'Installing NixOS'

# install
${NIXOSINSTALL} --no-root-passwd --flake "${FLAKEDIR}#${HOSTNAME}" "$@"
