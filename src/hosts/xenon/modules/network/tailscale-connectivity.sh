#!/usr/bin/env bash

### CONFIGURATION ###

interface="$1"
status="$2"

### MAIN ###

# Only react to interfaces coming up and to connectivity changes
case "${status}" in
up)
	# Ignore the loopback interface
	if [[ ${interface} == lo ]]; then
		exit 0
	fi
	;;
connectivity-change)
	;;
*)
	exit 0
	;;
esac

printf '%s\n' 'Reconciling Tailscale connection'

# Clear a previous failure so the service can be started again
if systemctl is-failed --quiet tailscale-up.service; then
	systemctl reset-failed tailscale-up.service
fi

systemctl --no-block start tailscale-up.service

exit 0
