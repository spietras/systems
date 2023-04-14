#!/bin/sh

### HELPER FUNCTIONS ###

print_usage() {
    # Print script usage

    cat <<EOF
Usage: $0
Check flake correctness.
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

### MAIN ###

nix --extra-experimental-features 'nix-command flakes' flake check "$@"
