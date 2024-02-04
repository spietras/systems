#!/bin/sh

### CONFIGURATION ###

CLIENT_ID='@clientId@'
CLIENT_SECRET='@clientSecret@'
CURL='@curl@'
JQ='@jq@'
MKTEMP='@mktemp@'
RM='@rm@'
TAILSCALE='@tailscale@'
XARGS='@xargs@'

### MAIN ###

# Create temporary file for access token
idfile="$(${MKTEMP})"
secretfile="$(${MKTEMP})"
tokenfile="$(${MKTEMP})"
keyfile="$(${MKTEMP})"

# Put client ID and secret into temporary files
${XARGS} -0 printf 'client_id=%s' <"${CLIENT_ID}" >"${idfile}"
${XARGS} -0 printf 'client_secret=%s' <"${CLIENT_SECRET}" >"${secretfile}"

# Get access token from Tailscale API
${CURL} --silent 'https://api.tailscale.com/api/v2/oauth/token' \
	--data "@${idfile}" \
	--data "@${secretfile}" |
	${JQ} --raw-output '.access_token' |
	${XARGS} -0 printf 'Authorization: Bearer %s' >"${tokenfile}"

# Create single-use authkey
${CURL} --silent 'https://api.tailscale.com/api/v2/tailnet/-/keys' \
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
}' |
	${JQ} --raw-output '.key' >"${keyfile}"

# Connect to Tailscale
${TAILSCALE} up "--authkey=file:${keyfile}"

# Clean up temporary files
${RM} --force "${idfile}" "${secretfile}" "${tokenfile}" "${keyfile}"
