#!/bin/sh

### CONFIGURATION ###

MAIN_LABEL='@main@'
ZFS_HARDSTATE='@hardstate@'
ZFS_SOFTSTATE='@softstate@'
HARDSTATE_DIRECTORIES='@hardstateDirectories@'
SOFTSTATE_DIRECTORIES='@softstateDirectories@'

UDEVADM='@udevadm@'

### PREPARATION ###

# force udev to reread filesystems
${UDEVADM} trigger

printf '%s' "Waiting for filesystems to appear..."
while [ ! -e "/dev/disk/by-label/${MAIN_LABEL}" ]; do
	sleep 1
	printf '%s' '.'
done
echo

echo "Importing ZFS pool"

if ! zpool import -aN -d "/dev/disk/by-label/${MAIN_LABEL}"; then
	echo "Importing ZFS pool failed" >&2
	exit 1
fi

echo "Mounting persistent filesystems"

if ! mkdir -p "/mnt/${ZFS_HARDSTATE}/" "/mnt/${ZFS_SOFTSTATE}/" ||
	! mount -t zfs -o zfsutil "${MAIN_LABEL}/${ZFS_HARDSTATE}" "/mnt/${ZFS_HARDSTATE}/" ||
	! mount -t zfs -o zfsutil "${MAIN_LABEL}/${ZFS_SOFTSTATE}" "/mnt/${ZFS_SOFTSTATE}/"; then
	echo "Mounting filesystems failed" >&2
	exit 2
fi

echo "Creating necessary directories"

create_directories() {
	for directory in $(echo "${HARDSTATE_DIRECTORIES}" | tr ':' ' '); do
		set -- "/mnt/${ZFS_HARDSTATE}/${directory}" "$@"
	done

	for directory in $(echo "${SOFTSTATE_DIRECTORIES}" | tr ':' ' '); do
		set -- "/mnt/${ZFS_SOFTSTATE}/${directory}" "$@"
	done

	mkdir -p "$@"
}

# if ! create_directories; then
# 	echo "Creating directories failed" >&2
# 	exit 3
# fi

echo "Unmounting persistent filesystems"

if ! umount "/mnt/${ZFS_HARDSTATE}/" "/mnt/${ZFS_SOFTSTATE}/"; then
	echo "Unmounting filesystems failed" >&2
	exit 4
fi

echo "Preparation complete"
