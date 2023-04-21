#!/bin/sh

### PARSE ARGUMENTS ###

tailscale=''
key=''
unparsed=''

while [ -n "${1:-}" ]; do
    case "$1" in
    -t | --tailscale)
        shift
        tailscale="$1"
        ;;
    -k | --key)
        shift
        key="$1"
        ;;
    --)
        shift
        unparsed="$unparsed $*"
        break
        ;;
    *) unparsed="$unparsed $1" ;;
    esac
    shift
done

# shellcheck disable=SC2086
set -- $unparsed

### MAIN ###

$tailscale up --authkey "$(cat "$key")" "$@"
