#!/bin/sh

### CONFIGURATION ###
STATUS="$2"
CHRONYC='@chronyc@'

### MAIN ###

case "${STATUS}" in
up | down | connectivity-change | dhcp6-change)
	echo "Switching sources to appropriate state"

	${CHRONYC} onoffline >/dev/null 2>&1
	;;
*) ;;
esac

exit 0
