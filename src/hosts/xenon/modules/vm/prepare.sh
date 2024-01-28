#!/bin/sh

### CONFIGURATION ###

DISK='@disk@'
MAIN_LABEL='@main@'
SWAP_LABEL='@swap@'
ZFS_NIX='@nix@'
ZFS_HOME='@home@'
ZFS_HARDSTATE='@hardstate@'
ZFS_SOFTSTATE='@softstate@'
SWAP_SIZE='@swapsize@'

PARTED='@parted@'
UDEVADM='@udevadm@'
ZPOOL='@zpool@'
ZFS='@zfs@'
MKSWAP='@mkswap@'

### PARTITIONING ###

echo "Partitioning disk ${DISK}"

# partition the disk
# use GPT to store partition metadata
# swap partition at the end
# and the rest is for the main partition
if ! ${PARTED} --script --align optimal "${DISK}" -- \
	mklabel gpt \
	mkpart "${MAIN_LABEL}" 1MB "-${SWAP_SIZE}" \
	mkpart "${SWAP_LABEL}" linux-swap "-${SWAP_SIZE}" 100%; then
	echo "Partitioning failed" >&2
	exit 1
fi

# force udev to reread partition table
${UDEVADM} trigger

printf '%s' "Waiting for partitions to appear..."
while [ ! -e "/dev/disk/by-partlabel/${MAIN_LABEL}" ] ||
	[ ! -e "/dev/disk/by-partlabel/${SWAP_LABEL}" ]; do
	sleep 1
	printf '%s' '.'
done
echo

echo "Partitioning complete"

### FORMATTING ###

# format the partitions with appropriate filesystems
# note that referring to devices by by-partlabel works only when using GPT

echo "Creating ZFS pool ${MAIN_LABEL} on /dev/disk/by-partlabel/${MAIN_LABEL}"

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
	echo "Creating ZFS pool failed" >&2
	exit 2
fi

echo "Creating ZFS datasets"

if ! ${ZFS} create -o compression=on "${MAIN_LABEL}/${ZFS_NIX}" ||
	! ${ZFS} create -o compression=on "${MAIN_LABEL}/${ZFS_HOME}" ||
	! ${ZFS} create -o compression=on "${MAIN_LABEL}/${ZFS_HARDSTATE}" ||
	! ${ZFS} create -o compression=on "${MAIN_LABEL}/${ZFS_SOFTSTATE}"; then
	echo "Creating ZFS datasets failed" >&2
	exit 3
fi

echo "Formatting /dev/disk/by-partlabel/${SWAP_LABEL} as swap"

# swap is just swap
if ! ${MKSWAP} -L "${SWAP_LABEL}" "/dev/disk/by-partlabel/${SWAP_LABEL}"; then
	echo "Formatting swap partition failed" >&2
	exit 4
fi

# force udev to reread filesystems
${UDEVADM} trigger

printf '%s' "Waiting for filesystems to appear..."
while [ ! -e "/dev/disk/by-label/${MAIN_LABEL}" ] ||
	[ ! -e "/dev/disk/by-label/${SWAP_LABEL}" ]; do
	sleep 1
	printf '%s' '.'
done
echo

echo "Formatting complete"

### PREPARATION ###

echo "Mounting persistent filesystems"

if ! mkdir -p "/mnt/${ZFS_HARDSTATE}/" "/mnt/${ZFS_SOFTSTATE}/" ||
	! mount -t zfs -o zfsutil "${MAIN_LABEL}/${ZFS_HARDSTATE}" "/mnt/${ZFS_HARDSTATE}/" ||
	! mount -t zfs -o zfsutil "${MAIN_LABEL}/${ZFS_SOFTSTATE}" "/mnt/${ZFS_SOFTSTATE}/"; then
	echo "Mounting filesystems failed" >&2
	exit 7
fi

echo "Creating necessary directories"

if ! mkdir -p \
	"/mnt/${ZFS_SOFTSTATE}/etc/NetworkManager/system-connections/" \
	"/mnt/${ZFS_SOFTSTATE}/var/cache/" \
	"/mnt/${ZFS_SOFTSTATE}/var/games/" \
	"/mnt/${ZFS_SOFTSTATE}/var/lib/" \
	"/mnt/${ZFS_SOFTSTATE}/var/log/" \
	"/mnt/${ZFS_SOFTSTATE}/var/tmp/" \
	; then
	echo "Creating directories failed" >&2
	exit 8
fi

echo "Unmounting persistent filesystems"

if ! umount "/mnt/${ZFS_HARDSTATE}/" "/mnt/${ZFS_SOFTSTATE}/"; then
	echo "Unmounting filesystems failed" >&2
	exit 9
fi

echo "Preparation complete"
