#!/bin/sh

### CONFIGURATION ###
INTERFACE="$1"
STATUS="$2"
CHRONYC='@chronyc@'
SOURCEDIR="@sourcedir@"
SOURCEFILE="/var/run/chrony/${SOURCEDIR}/${INTERFACE}.sources"

# make sure we're always getting the standard response strings
export LC_ALL=C

### PREPARATION ###

if [ -z "${INTERFACE}" ] || [ "${INTERFACE}" = 'none' ]; then
	exit 0
fi

# make sure the sources directory exists and has the right permissions
mkdir -p /var/run/chrony
chmod 750 /var/run/chrony
chown chrony:chrony /var/run/chrony

mkdir -p "/var/run/chrony/${SOURCEDIR}"
chmod 750 "/var/run/chrony/${SOURCEDIR}"
chown chrony:chrony "/var/run/chrony/${SOURCEDIR}"

touch "${SOURCEFILE}"
chmod 640 "${SOURCEFILE}"
chown chrony:chrony "${SOURCEFILE}"

### MAIN ###

case "${STATUS}" in
up | dhcp4-change | dhcp6-change)
	for server in ${DHCP4_NTP_SERVERS:-} ${DHCP6_DHCP6_NTP_SERVERS:-}; do
		# Check for invalid characters
		len1=$(printf '%s' "${server}" | wc -c)
		len2=$(printf '%s' "${server}" | tr -d -c 'A-Za-z0-9:.-' | wc -c)
		if [ "${len1}" -ne "${len2}" ] || [ "${len2}" -lt 1 ] || [ "${len2}" -gt 255 ]; then
			continue
		fi

		echo "Adding NTP server ${server} to dynamic sources"

		echo "server ${server} iburst" >>"${SOURCEFILE}"
	done

	${CHRONYC} reload sources >/dev/null 2>&1
	;;
down)
	echo "Removing all previous NTP servers from dynamic sources"

	printf '' >"${SOURCEFILE}"
	${CHRONYC} reload sources >/dev/null 2>&1
	;;
*) ;;
esac

exit 0
