#!/usr/bin/env bash

### CONFIGURATION ###

status="$2"

### MAIN ###

case "${status}" in
up | down | connectivity-change | dhcp6-change)
	printf '%s\n' 'Switching sources to appropriate state'

	chronyc onoffline >/dev/null 2>&1
	;;
*) ;;
esac

exit 0
