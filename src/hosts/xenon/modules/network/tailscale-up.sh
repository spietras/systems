#!/usr/bin/env bash

set -o pipefail

### CONFIGURATION ###

CLIENT_ID='@clientId@'
CLIENT_SECRET='@clientSecret@'
IP='@ip@'
ROUTES='@routes@'

### MAIN ###

# Create temporary file for access token
idfile="$(mktemp)"
secretfile="$(mktemp)"
tokenfile="$(mktemp)"
keyfile="$(mktemp)"

# Remove temporary credentials when the script exits
trap 'rm --force "${idfile}" "${secretfile}" "${tokenfile}" "${keyfile}"' EXIT

# Put client ID and secret into temporary files
xargs -0 printf 'client_id=%s' <"${CLIENT_ID}" >"${idfile}"
xargs -0 printf 'client_secret=%s' <"${CLIENT_SECRET}" >"${secretfile}"

# Get access token from Tailscale API
curl \
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
	xargs -0 printf 'Authorization: Bearer %s' >"${tokenfile}"

# Create single-use authkey
curl \
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
' \
	--fail-with-body \
	--header @"${tokenfile}" \
	--max-time 30 \
	--retry 5 \
	--retry-all-errors \
	--retry-delay 2 \
	--show-error \
	--silent \
	'https://api.tailscale.com/api/v2/tailnet/-/keys' |
	jq --raw-output '.key' >"${keyfile}"

# Connect to Tailscale
tailscale up \
	--accept-routes \
	--advertise-routes="${ROUTES}" \
	--authkey="file:${keyfile}" \
	--netfilter-mode=off

# Get device id
device="$(tailscale status --json | jq --raw-output '.Self.ID')"

# Set device IP address
curl \
	--data-binary '
{
  "ipv4": "'"${IP}"'"
}
' \
	--fail-with-body \
	--header @"${tokenfile}" \
	--max-time 30 \
	--retry 15 \
	--retry-all-errors \
	--retry-delay 2 \
	--retry-max-time 60 \
	--show-error \
	--silent \
	"https://api.tailscale.com/api/v2/device/${device}/ip"
