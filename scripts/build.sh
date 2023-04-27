#!/bin/sh

### HELPER FUNCTIONS ###

print_usage() {
    # Print script usage

    cat <<EOF
Usage: $0 TARGET
Build specified target.

    TARGET                  target name
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

target="$1"

if [ -z "$target" ]; then
    echo "Error: missing TARGET argument" >&2
    echo >&2
    print_usage >&2
    exit 1
fi

shift

### MAIN ###

nix --extra-experimental-features 'nix-command flakes' build ".#$target" "$@"
