#!/usr/bin/env bash

set -o pipefail

### CONFIGURATION ###

SOURCEDIR="@sourcedir@"

interface="$1"
status="$2"

sourcefile="/var/run/chrony/${SOURCEDIR}/${interface}.sources"

# make sure we're always getting the standard response strings
export LC_ALL=C

### PREPARATION ###

if [[ -z ${interface} ]] || [[ ${interface} == 'none' ]]; then
	exit 0
fi

# make sure the sources directory exists and has the right permissions
mkdir --parents /var/run/chrony/
chmod 750 /var/run/chrony/
chown chrony:chrony /var/run/chrony/

mkdir --parents "/var/run/chrony/${SOURCEDIR}/"
chmod 750 "/var/run/chrony/${SOURCEDIR}/"
chown chrony:chrony "/var/run/chrony/${SOURCEDIR}/"

touch "${sourcefile}"
chmod 640 "${sourcefile}"
chown chrony:chrony "${sourcefile}"

### MAIN ###

case "${status}" in
up | dhcp4-change | dhcp6-change)
	for server in ${DHCP4_NTP_SERVERS:-} ${DHCP6_DHCP6_NTP_SERVERS:-}; do
		# Check for invalid characters
		len1=$(printf '%s' "${server}" | wc --bytes)
		len2=$(printf '%s' "${server}" | tr --delete --complement 'A-Za-z0-9:.-' | wc --bytes)
		if [[ ${len1} -ne ${len2} ]] || [[ ${len2} -lt 1 ]] || [[ ${len2} -gt 255 ]]; then
			continue
		fi

		printf '%s\n' "Adding NTP server ${server} to dynamic sources"

		printf '%s\n' "server ${server} iburst" >>"${sourcefile}"
	done

	chronyc reload sources >/dev/null 2>&1
	;;
down)
	printf '%s\n' 'Removing all previous NTP servers from dynamic sources'

	printf '' >"${sourcefile}"
	chronyc reload sources >/dev/null 2>&1
	;;
*) ;;
esac

exit 0
