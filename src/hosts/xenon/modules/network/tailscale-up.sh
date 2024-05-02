#!/usr/bin/env bash

set -o pipefail

### CONFIGURATION ###

CLIENT_ID='@clientId@'
CLIENT_SECRET='@clientSecret@'
IP='@ip@'

### MAIN ###

# Create temporary file for access token
idfile="$(mktemp)"
secretfile="$(mktemp)"
tokenfile="$(mktemp)"
keyfile="$(mktemp)"

# Put client ID and secret into temporary files
xargs -0 printf 'client_id=%s' <"${CLIENT_ID}" >"${idfile}"
xargs -0 printf 'client_secret=%s' <"${CLIENT_SECRET}" >"${secretfile}"

# Get access token from Tailscale API
curl --silent 'https://api.tailscale.com/api/v2/oauth/token' \
	--data "@${idfile}" \
	--data "@${secretfile}" |
	jq --raw-output '.access_token' |
	xargs -0 printf 'Authorization: Bearer %s' >"${tokenfile}"

# Create single-use authkey
curl --silent 'https://api.tailscale.com/api/v2/tailnet/-/keys' \
	--header @"${tokenfile}" \
	--data-binary '
{
  "capabilities": {
    "devices": {
      "create": {
        "reusable": true,
        "ephemeral": true,
        "preauthorized": true,
        "tags": [ "tag:host" ]
      }
    }
  }
}
' |
	jq --raw-output '.key' >"${keyfile}"

# Connect to Tailscale
tailscale up "--authkey=file:${keyfile}" --netfilter-mode=off

# Get device id
device="$(tailscale status --json | jq --raw-output '.Self.ID')"

# Set device IP address
curl --silent "https://api.tailscale.com/api/v2/device/${device}/ip" \
	--header @"${tokenfile}" \
	--data-binary '
{
  "ipv4": "'"${IP}"'"
}
'

# Clean up temporary files
rm --force "${idfile}" "${secretfile}" "${tokenfile}" "${keyfile}"
