#!/bin/sh

### HELPER FUNCTIONS ###

print_usage() {
    # Print script usage

    cat <<EOF
Usage: $0 HOST
Run NixOS virtual machine.

    HOST                    host name (must exist in ./hosts)
EOF
}

### PARSE ARGUMENTS ###

unparsed=''

while [ -n "${1:-}" ]; do
    case "$1" in
    -h | --help)
        print_usage >&2
        exit
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

host="$1"

if [ -z "$host" ]; then
    echo "Error: missing HOST argument" >&2
    echo >&2
    print_usage >&2
    exit 1
fi

shift

### MAIN ###

nix --extra-experimental-features 'nix-command flakes' run ".#$host-vm" -- "$@"
