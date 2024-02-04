#!/bin/sh

### CONFIGURATION ###

BOOT_LABEL='@boot@'
CAT='@cat@'
CP='@cp@'
DISK='@disk@'
FLAKEDIR='@flake@'
GREP='@grep@'
ZFS_HARDSTATE='@hardstate@'
ZFS_HOME='@home@'
HOSTNAME='@host@'
MAIN_LABEL='@main@'
MKDIR='@mkdir@'
MKFSFAT='@mkfsfat@'
MKSWAP='@mkswap@'
MOUNT='@mount@'
MOUNTPOINT='@mountpoint@'
ZFS_NIX='@nix@'
NIXOSINSTALL='@nixosinstall@'
PARTED='@parted@'
PRINTF='@printf@'
RM='@rm@'
ZFS_SOFTSTATE='@softstate@'
SLEEP='@sleep@'
SWAP_LABEL='@swap@'
SWAPOFF='@swapoff'
SWAPON='@swapon@'
SWAP_SIZE='@swapsize@'
UDEVADM='@udevadm@'
UMOUNT='@umount@'
ZFS='@zfs@'
ZPOOL='@zpool@'

### HELPER FUNCTIONS ###

print_usage() {
	# Print script usage

	${CAT} <<EOF
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

${PRINTF} '%s\n' 'Cleaning up old state'

# remove old age key if exists
${RM} --force "/mnt/${ZFS_HARDSTATE}/sops/age/keys.txt"

# unmount everything
${MOUNTPOINT} --quiet /mnt/ && ${UMOUNT} --recursive /mnt/

# disable swap
${SWAPOFF} "/dev/disk/by-partlabel/${SWAP_LABEL}" 2>/dev/null || true

# destroy zfs pool
${ZPOOL} list -H -o name | ${GREP} --quiet "${MAIN_LABEL}" && ${ZPOOL} destroy -f "${MAIN_LABEL}"

### PARTITIONING ###

${PRINTF} '%s\n' "Partitioning disk ${DISK}"

# partition the disk
# use GPT to store partition metadata
# boot partition at the beginning
# swap partition at the end
# and the rest is for the main partition
if ! ${PARTED} --script --align optimal "${DISK}" -- \
	mklabel gpt \
	mkpart "${BOOT_LABEL}" fat32 1MB 512MB \
	set 1 boot on \
	set 1 esp on \
	mkpart "${MAIN_LABEL}" 512MB "-${SWAP_SIZE}" \
	mkpart "${SWAP_LABEL}" linux-swap "-${SWAP_SIZE}" 100%; then
	${PRINTF} '%s\n' 'Partitioning failed' >&2
	exit 1
fi

# force udev to reread partition table
${UDEVADM} trigger

${PRINTF} '%s' 'Waiting for partitions to appear...'
while [ ! -e "/dev/disk/by-partlabel/${MAIN_LABEL}" ] ||
	[ ! -e "/dev/disk/by-partlabel/${SWAP_LABEL}" ]; do
	${SLEEP} 1
	printf '%s' '.'
done
${PRINTF} '\n'

${PRINTF} '%s\n' 'Partitioning complete'

### FORMATTING ###

# format the partitions with appropriate filesystems
# note that referring to devices by by-partlabel works only when using GPT

${PRINTF} '%s\n' "Formatting /dev/disk/by-partlabel/${BOOT_LABEL} with FAT32"

# fat32 for the boot partition
if ! ${MKFSFAT} -c -F 32 -n "${BOOT_LABEL}" "/dev/disk/by-partlabel/${BOOT_LABEL}"; then
	${PRINTF} '%s\n' 'Formatting boot partition failed' >&2
	exit 2
fi

${PRINTF} '%s\n' "Creating ZFS pool ${MAIN_LABEL} on /dev/disk/by-partlabel/${MAIN_LABEL}"

# setup main partition with zfs
if ! ${ZPOOL} create -f \
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
	"${MAIN_LABEL}" "/dev/disk/by-partlabel/${MAIN_LABEL}"; then
	${PRINTF} '%s\n' 'Creating ZFS pool failed' >&2
	exit 3
fi

${PRINTF} '%s\n' 'Creating ZFS datasets'

if ! ${ZFS} create -o compression=on "${MAIN_LABEL}/${ZFS_HARDSTATE}" ||
	! ${ZFS} create -o compression=on "${MAIN_LABEL}/${ZFS_HOME}" ||
	! ${ZFS} create -o compression=on "${MAIN_LABEL}/${ZFS_NIX}" ||
	! ${ZFS} create -o compression=on "${MAIN_LABEL}/${ZFS_SOFTSTATE}"; then
	${PRINTF} '%s\n' 'Creating ZFS datasets failed' >&2
	exit 4
fi

${PRINTF} '%s\n' "Formatting /dev/disk/by-partlabel/${SWAP_LABEL} as swap"

# swap is just swap
if ! ${MKSWAP} -c -L "${SWAP_LABEL}" "/dev/disk/by-partlabel/${SWAP_LABEL}"; then
	${PRINTF} '%s\n' 'Formatting swap partition failed' >&2
	exit 5
fi

# force udev to reread filesystems
${UDEVADM} trigger

printf '%s' 'Waiting for filesystems to appear...'
while [ ! -e "/dev/disk/by-label/${BOOT_LABEL}" ] ||
	[ ! -e "/dev/disk/by-label/${MAIN_LABEL}" ] ||
	[ ! -e "/dev/disk/by-label/${SWAP_LABEL}" ]; do
	${SLEEP} 1
	printf '%s' '.'
done
${PRINTF} '\n'

${PRINTF} '%s\n' 'Formatting complete'

### PREPARATION ###

${PRINTF} '%s\n' 'Enabling swap'

# enable swap already so installation can use more memory
if ! ${SWAPON} "/dev/disk/by-partlabel/${SWAP_LABEL}"; then
	${PRINTF} '%s\n' 'Enabling swap failed' >&2
	exit 6
fi

${PRINTF} '%s\n' 'Mounting filesystems'

# mount everything
if ! ${MOUNT} --types tmpfs --options mode=755 none /mnt/ ||
	! ${MKDIR} --parents /mnt/boot/ /mnt/home/ /mnt/nix/ "/mnt/${ZFS_HARDSTATE}/" "/mnt/${ZFS_SOFTSTATE}/" ||
	! ${MOUNT} --types vfat "/dev/disk/by-label/${BOOT_LABEL}" /mnt/boot/ ||
	! ${MOUNT} --types zfs --options zfsutil "${MAIN_LABEL}/${ZFS_HOME}" /mnt/home/ ||
	! ${MOUNT} --types zfs --options zfsutil "${MAIN_LABEL}/${ZFS_NIX}" /mnt/nix/ ||
	! ${MOUNT} --types zfs --options zfsutil "${MAIN_LABEL}/${ZFS_HARDSTATE}" "/mnt/${ZFS_HARDSTATE}/" ||
	! ${MOUNT} --types zfs --options zfsutil "${MAIN_LABEL}/${ZFS_SOFTSTATE}" "/mnt/${ZFS_SOFTSTATE}/"; then
	${PRINTF} '%s\n' 'Mounting filesystems failed' >&2
	exit 7
fi

${PRINTF} '%s\n' 'Copying age keys'

# copy age keys
if ! ${MKDIR} --parents "/mnt/${ZFS_HARDSTATE}/sops/age/" ||
	! ${CP} "${keyfile}" "/mnt/${ZFS_HARDSTATE}/sops/age/keys.txt"; then
	${PRINTF} '%s\n' 'Copying age keys failed' >&2
	exit 8
fi

### INSTALLATION ###

${PRINTF} '%s\n' 'Installing NixOS'

# install
${NIXOSINSTALL} --no-root-passwd --flake "${FLAKEDIR}#${HOSTNAME}" "$@"
