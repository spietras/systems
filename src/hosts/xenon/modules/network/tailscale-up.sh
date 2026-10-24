#!/usr/bin/env bash

set -o pipefail

### CONFIGURATION ###

CLIENT_ID='@clientId@'
CLIENT_SECRET='@clientSecret@'
IP='@ip@'
ROUTES='@routes@'

### MAIN ###

# Create temporary files
idfile="$(mktemp)"
keyfile="$(mktemp)"
secretfile="$(mktemp)"
tokenfile="$(mktemp)"

# Remove temporary files when the script exits
trap 'rm --force "${idfile}" "${keyfile}" "${secretfile}" "${tokenfile}"' EXIT

# Put client ID and secret into temporary files
xargs -0 printf 'client_id=%s' <"${CLIENT_ID}" >"${idfile}"
xargs -0 printf 'client_secret=%s' <"${CLIENT_SECRET}" >"${secretfile}"

# Write the auth key with the desired parameters
awk 1 ORS='?ephemeral=true&preauthorized=true' "${CLIENT_SECRET}" >"${keyfile}"

# Get access token from Tailscale API

if ! curl \
	--data "@${idfile}" \
	--data "@${secretfile}" \
	--fail-with-body \
	--max-time 30 \
	--retry 5 \
	--retry-all-errors \
	--retry-delay 2 \
	--show-error \
	--silent \
	'https://api.tailscale.com/api/v2/oauth/token' |
	jq --raw-output '.access_token' |
	xargs -0 printf 'Authorization: Bearer %s' >"${tokenfile}"; then
	printf '%s\n' 'Failed to get an access token from the Tailscale API' >&2
	exit 1
fi

# Get local Tailscale state
if ! status="$(tailscale status --json)"; then
	printf '%s\n' 'Failed to get the local Tailscale state' >&2
	exit 1
fi

node="$(printf '%s\n' "${status}" | jq --raw-output '.Self.ID // ""')"
state="$(printf '%s\n' "${status}" | jq --raw-output '.BackendState // ""')"

# Check whether the node still exists in the control plane
if [[ -n ${node} ]]; then
	code="$(curl \
		--fail \
		--header @"${tokenfile}" \
		--max-time 30 \
		--output /dev/null \
		--retry 10 \
		--retry-all-errors \
		--retry-delay 5 \
		--retry-max-time 60 \
		--show-error \
		--silent \
		--write-out '%{http_code}' \
		"https://api.tailscale.com/api/v2/device/${node}")" || true

	case "${code}" in
	200)
		;;
	404)
		node=""
		;;
	*)
		printf '%s\n' 'Could not determine the Tailscale node state' >&2
		exit 1
		;;
	esac
fi

# Clear the local state when there is no node in the control plane
if [[ -z ${node} ]]; then
	printf '%s\n' 'Clearing the stale local Tailscale state'

	tailscale logout || true
fi

if [[ -z ${node} || ${state} != Running ]]; then
	printf '%s\n' 'Connecting to Tailscale'

	if ! tailscale up \
		--accept-routes \
		--advertise-routes="${ROUTES}" \
		--advertise-tags="tag:host" \
		--auth-key="file:${keyfile}" \
		--netfilter-mode=off \
		--timeout=60s; then
		printf '%s\n' 'Failed to connect to Tailscale' >&2
		exit 1
	fi

	# Get device ID
	node="$(tailscale status --json | jq --raw-output '.Self.ID')"
fi

# Set device IP address
if ! curl \
	--data-binary '
{
  "ipv4": "'"${IP}"'"
}
' \
	--fail-with-body \
	--header @"${tokenfile}" \
	--max-time 30 \
	--output /dev/null \
	--retry 10 \
	--retry-all-errors \
	--retry-delay 5 \
	--retry-max-time 60 \
	--show-error \
	--silent \
	"https://api.tailscale.com/api/v2/device/${node}/ip"; then
	printf '%s\n' 'Failed to set the Tailscale node IP address' >&2
	exit 1
fi
