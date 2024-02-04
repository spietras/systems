#!/bin/sh

### CONFIGURATION ###

ZFS_HARDSTATE='@hardstate@'
HARDSTATE_DIRECTORIES='@hardstateDirectories@'
MAIN_LABEL='@main@'
MKDIR='@mkdir@'
MOUNT='@mount@'
ZFS_SOFTSTATE='@softstate@'
PRINTF='@printf@'
SLEEP='@sleep@'
SOFTSTATE_DIRECTORIES='@softstateDirectories@'
TR='@tr@'
UDEVADM="@udevadm@"
UMOUNT='@umount@'
ZPOOL='@zpool@'

### PREPARATION ###

# force udev to reread filesystems
${UDEVADM} trigger

${PRINTF} '%s' 'Waiting for filesystems to appear...'
while [ ! -e "/dev/disk/by-label/${MAIN_LABEL}" ]; do
	${SLEEP} 1
	${PRINTF} '%s' '.'
done
${PRINTF} '\n'

${PRINTF} '%s\n' 'Importing ZFS pool'

if ! ${ZPOOL} import -aN -d "/dev/disk/by-label/${MAIN_LABEL}"; then
	${PRINTF} '%s\n' 'Importing ZFS pool failed' >&2
	exit 1
fi

${PRINTF} '%s\n' 'Mounting persistent filesystems'

if ! ${MKDIR} --parents "/mnt/${ZFS_HARDSTATE}/" "/mnt/${ZFS_SOFTSTATE}/" ||
	! ${MOUNT} --types zfs --options zfsutil "${MAIN_LABEL}/${ZFS_HARDSTATE}" "/mnt/${ZFS_HARDSTATE}/" ||
	! ${MOUNT} --types zfs --options zfsutil "${MAIN_LABEL}/${ZFS_SOFTSTATE}" "/mnt/${ZFS_SOFTSTATE}/"; then
	${PRINTF} '%s\n' 'Mounting filesystems failed' >&2
	exit 2
fi

${PRINTF} '%s\n' 'Creating necessary directories'

create_directories() {
	for directory in $(${PRINTF} '%s' "${HARDSTATE_DIRECTORIES}" | ${TR} ':' ' '); do
		set -- "/mnt/${ZFS_HARDSTATE}/${directory}" "$@"
	done

	for directory in $(${PRINTF} '%s' "${SOFTSTATE_DIRECTORIES}" | ${TR} ':' ' '); do
		set -- "/mnt/${ZFS_SOFTSTATE}/${directory}" "$@"
	done

	${MKDIR} --parents "$@"
}

if ! create_directories; then
	${PRINTF} '%s\n' 'Creating directories failed' >&2
	exit 3
fi

${PRINTF} '%s\n' 'Unmounting persistent filesystems'

if ! ${UMOUNT} "/mnt/${ZFS_HARDSTATE}/" "/mnt/${ZFS_SOFTSTATE}/"; then
	${PRINTF} '%s\n' 'Unmounting filesystems failed' >&2
	exit 4
fi

${PRINTF} '%s\n' 'Preparation complete'
