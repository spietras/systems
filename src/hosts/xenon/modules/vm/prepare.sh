#!/bin/sh

### CONFIGURATION ###

# Don't try to make the script self-contained
# Just use binaries that are already available
# This is because this goes to initrd
# And initrd goes to boot partition which is small

DISK='@disk@'
HARDSTATE='@hardstate@'
HOME='@home@'
LONGHORN='@longhorn@'
LONGHORN_SIZE='@longhornSize@'
MAIN='@main@'
MKFSEXT4='@mkfsext4@'
NIX='@nix@'
PARTED='@parted@'
SOFTSTATE='@softstate@'
SWAP='@swap@'
SWAP_SIZE='@swapSize@'
ZFS_PACKAGE='@zfsPackage@'

### PREPARATION ###

# install ZFS udev rules
mkdir --parents /etc/udev/rules.d/
cp "${ZFS_PACKAGE}"/lib/udev/rules.d/*.rules /etc/udev/rules.d/
udevadm control --reload-rules

### PARTITIONING ###

printf '%s\n' "Partitioning disk ${DISK}"

# partition the disk
# use GPT to store partition metadata
# swap partition at the end
# and the rest is for the main partition
if ! ${PARTED} --script --align optimal "${DISK}" -- \
	mklabel gpt \
	mkpart "${MAIN}" 1MB "-${SWAP_SIZE}" \
	mkpart "${SWAP}" linux-swap "-${SWAP_SIZE}" 100%; then
	printf '%s\n' 'Partitioning failed' >&2
	exit 1
fi

# force udev to reread partition table
udevadm trigger

printf '%s' 'Waiting for partitions to appear...'
while [ ! -e "/dev/disk/by-partlabel/${MAIN}" ] ||
	[ ! -e "/dev/disk/by-partlabel/${SWAP}" ]; do
	sleep 1
	printf '%s' '.'
done
printf '\n'

printf '%s\n' 'Partitioning complete'

### FORMATTING ###

# format the partitions with appropriate filesystems
# note that referring to devices by by-partlabel works only when using GPT

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
	exit 2
fi

printf '%s\n' 'Creating ZFS datasets'

if ! "${ZFS_PACKAGE}/bin/zfs" create -o compression=on "${MAIN}/${NIX}" ||
	! "${ZFS_PACKAGE}/bin/zfs" create -o compression=on "${MAIN}/${HOME}" ||
	! "${ZFS_PACKAGE}/bin/zfs" create -o compression=on "${MAIN}/${HARDSTATE}" ||
	! "${ZFS_PACKAGE}/bin/zfs" create -o compression=on "${MAIN}/${SOFTSTATE}"; then
	printf '%s\n' 'Creating ZFS datasets failed' >&2
	exit 3
fi

printf '%s\n' 'Creating ZFS volumes'

if ! "${ZFS_PACKAGE}/bin/zfs" create -o compression=on -V "${LONGHORN_SIZE}" "${MAIN}/${LONGHORN}"; then
	printf '%s\n' 'Creating ZFS volumes failed' >&2
	exit 4
fi

# force udev to create device nodes for volumes
udevadm trigger

printf '%s' 'Waiting for volumes to appear...'
while [ ! -e "/dev/zvol/${MAIN}/${LONGHORN}" ]; do
	sleep 1
	printf '%s' '.'
done
printf '\n'

printf '%s\n' 'Formatting ZFS volumes'

if ! ${MKFSEXT4} -L "${LONGHORN}" "/dev/zvol/${MAIN}/${LONGHORN}"; then
	printf '%s\n' 'Formatting ZFS volumes failed' >&2
	exit 5
fi

printf '%s\n' "Formatting /dev/disk/by-partlabel/${SWAP} as swap"

# swap is just swap
if ! mkswap -L "${SWAP}" "/dev/disk/by-partlabel/${SWAP}"; then
	printf '%s\n' 'Formatting swap partition failed' >&2
	exit 6
fi

# force udev to reread filesystems
udevadm trigger

printf '%s' 'Waiting for filesystems to appear...'
while [ ! -e "/dev/disk/by-label/${MAIN}" ] ||
	[ ! -e "/dev/disk/by-label/${LONGHORN}" ] ||
	[ ! -e "/dev/disk/by-label/${SWAP}" ]; do
	sleep 1
	printf '%s' '.'
done
printf '\n'

printf '%s\n' 'Formatting complete'

### CLEANUP ###

# export the pool to make the state clean
"${ZFS_PACKAGE}/bin/zpool" export "${MAIN}"
