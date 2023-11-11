#!/bin/sh

### CONFIGURATION ###

MKTEMP='@mktemp@'
CURL='@curl@'
JQ='@jq@'
TAILSCALE='@tailscale@'
CLIENT_ID='@clientId@'
CLIENT_SECRET='@clientSecret@'

### MAIN ###

# Create temporary file for access token
idfile="$(${MKTEMP})"
secretfile="$(${MKTEMP})"
tokenfile="$(${MKTEMP})"
keyfile="$(${MKTEMP})"

# Put client ID and secret into temporary files
xargs -0 printf 'client_id=%s' <"${CLIENT_ID}" >"${idfile}"
xargs -0 printf 'client_secret=%s' <"${CLIENT_SECRET}" >"${secretfile}"

# Get access token from Tailscale API
${CURL} -s 'https://api.tailscale.com/api/v2/oauth/token' \
	-d "@${idfile}" \
	-d "@${secretfile}" |
	${JQ} -r '.access_token' |
	xargs -0 printf 'Authorization: Bearer %s' >"${tokenfile}"

# Create single-use authkey
${CURL} -s 'https://api.tailscale.com/api/v2/tailnet/-/keys' \
	-H @"${tokenfile}" \
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
}' |
	${JQ} -r '.key' >"${keyfile}"

# Connect to Tailscale
${TAILSCALE} up "--authkey=file:${keyfile}"

# Clean up temporary files
rm -f "${idfile}" "${secretfile}" "${tokenfile}" "${keyfile}"
