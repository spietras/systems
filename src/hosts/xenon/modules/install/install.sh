#!/usr/bin/env bash

### CONFIGURATION ###

FLAKE='@flake@'
HOST='@host@'
MAIN='@main@'

### HELPER FUNCTIONS ###

print_usage() {
	# Print script usage

	cat <<EOF
Usage: $0 [-k KEYFILE] [OPTIONS]
Install the system on this machine.

	-k, --keyfile           path to the age key file
EOF
}

### PARSE ARGUMENTS ###

keyfile="${SOPS_AGE_KEY_FILE:-${SOPS_AGE_KEY_DIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/sops/age}/keys.txt}"
unparsed=''

while [[ -n ${1:-} ]]; do
	case "$1" in
	-k | --keyfile)
		shift
		keyfile="$1"
		;;
	-h | --help)
		print_usage >&2
		exit
		;;
	--)
		shift
		unparsed="${unparsed} $*"
		break
		;;
	*) unparsed="${unparsed} $1" ;;
	esac
	shift
done

# shellcheck disable=SC2086
set -- ${unparsed}

if [[ ! -e ${keyfile} ]]; then
	printf '%s\n' "Error: Key file ${keyfile} does not exist." >&2
	print_usage >&2
	exit 1
fi

### MAIN ###

disko-install \
	--flake "${FLAKE}#${HOST}" \
	--disk main "${MAIN}" \
	--extra-files "${keyfile}" /var/lib/sops/age/keys.txt \
	--write-efi-boot-entries \
	"$@"
