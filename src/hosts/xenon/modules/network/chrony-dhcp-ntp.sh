#!/bin/sh

### CONFIGURATION ###

CHMOD='@chmod@'
CHOWN='@chown@'
CHRONYC='@chronyc@'
MKDIR='@mkdir@'
PRINTF='@printf@'
SOURCEDIR="@sourcedir@"
TOUCH='@touch@'
TR='@tr@'
WC='@wc@'

SOURCEFILE="/var/run/chrony/${SOURCEDIR}/${INTERFACE}.sources"

INTERFACE="$1"
STATUS="$2"

# make sure we're always getting the standard response strings
export LC_ALL=C

### PREPARATION ###

if [ -z "${INTERFACE}" ] || [ "${INTERFACE}" = 'none' ]; then
	exit 0
fi

# make sure the sources directory exists and has the right permissions
${MKDIR} --parents /var/run/chrony/
${CHMOD} 750 /var/run/chrony/
${CHOWN} chrony:chrony /var/run/chrony/

${MKDIR} --parents "/var/run/chrony/${SOURCEDIR}/"
${CHMOD} 750 "/var/run/chrony/${SOURCEDIR}/"
${CHOWN} chrony:chrony "/var/run/chrony/${SOURCEDIR}/"

${TOUCH} "${SOURCEFILE}"
${CHMOD} 640 "${SOURCEFILE}"
${CHOWN} chrony:chrony "${SOURCEFILE}"

### MAIN ###

case "${STATUS}" in
up | dhcp4-change | dhcp6-change)
	for server in ${DHCP4_NTP_SERVERS:-} ${DHCP6_DHCP6_NTP_SERVERS:-}; do
		# Check for invalid characters
		len1=$(${PRINTF} '%s' "${server}" | ${WC} --bytes)
		len2=$(${PRINTF} '%s' "${server}" | ${TR} --delete --complement 'A-Za-z0-9:.-' | ${WC} --bytes)
		if [ "${len1}" -ne "${len2}" ] || [ "${len2}" -lt 1 ] || [ "${len2}" -gt 255 ]; then
			continue
		fi

		${PRINTF} '%s\n' "Adding NTP server ${server} to dynamic sources"

		${PRINTF} '%s\n' "server ${server} iburst" >>"${SOURCEFILE}"
	done

	${CHRONYC} reload sources >/dev/null 2>&1
	;;
down)
	${PRINTF} '%s\n' 'Removing all previous NTP servers from dynamic sources'

	${PRINTF} '' >"${SOURCEFILE}"
	${CHRONYC} reload sources >/dev/null 2>&1
	;;
*) ;;
esac

exit 0
