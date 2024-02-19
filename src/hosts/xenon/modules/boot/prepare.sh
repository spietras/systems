#!/bin/sh

### CONFIGURATION ###

# Don't try to make the script self-contained
# Just use binaries that are already available
# This is because this goes to initrd
# And initrd goes to boot partition which is small

HARDSTATE='@hardstate@'
HARDSTATE_DIRECTORIES='@hardstateDirectories@'
MAIN='@main@'
SOFTSTATE='@softstate@'
SOFTSTATE_DIRECTORIES='@softstateDirectories@'

### PREPARATION ###

# force udev to reread filesystems
udevadm trigger

printf '%s' 'Waiting for filesystems to appear...'
while [ ! -e "/dev/disk/by-label/${MAIN}" ]; do
	sleep 1
	printf '%s' '.'
done
printf '\n'

printf '%s\n' 'Importing ZFS pool'

if ! zpool import -aN -d "/dev/disk/by-label/${MAIN}"; then
	printf '%s\n' 'Importing ZFS pool failed' >&2
	exit 1
fi

printf '%s\n' 'Mounting persistent filesystems'

if ! mkdir --parents "/mnt/${HARDSTATE}/" "/mnt/${SOFTSTATE}/" ||
	! mount --types zfs --options zfsutil "${MAIN}/${HARDSTATE}" "/mnt/${HARDSTATE}/" ||
	! mount --types zfs --options zfsutil "${MAIN}/${SOFTSTATE}" "/mnt/${SOFTSTATE}/"; then
	printf '%s\n' 'Mounting filesystems failed' >&2
	exit 2
fi

printf '%s\n' 'Creating necessary directories'

create_directories() {
	for directory in $(printf '%s' "${HARDSTATE_DIRECTORIES}" | tr ':' ' '); do
		set -- "/mnt/${HARDSTATE}/${directory}" "$@"
	done

	for directory in $(printf '%s' "${SOFTSTATE_DIRECTORIES}" | tr ':' ' '); do
		set -- "/mnt/${SOFTSTATE}/${directory}" "$@"
	done

	mkdir --parents "$@"
}

if ! create_directories; then
	printf '%s\n' 'Creating directories failed' >&2
	exit 3
fi

printf '%s\n' 'Unmounting persistent filesystems'

if ! umount "/mnt/${HARDSTATE}/" "/mnt/${SOFTSTATE}/"; then
	printf '%s\n' 'Unmounting filesystems failed' >&2
	exit 4
fi

printf '%s\n' 'Preparation complete'
