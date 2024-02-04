#!/bin/sh

### CONFIGURATION ###

CHRONYC='@chronyc@'
PRINTF='@printf@'

STATUS="$2"

### MAIN ###

case "${STATUS}" in
up | down | connectivity-change | dhcp6-change)
	${PRINTF} '%s\n' 'Switching sources to appropriate state'

	${CHRONYC} onoffline >/dev/null 2>&1
	;;
*) ;;
esac

exit 0
