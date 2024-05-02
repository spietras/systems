#!/usr/bin/env bash

### CONFIGURATION ###

FLAKE='@flake@'
HOST='@host@'

### HELPER FUNCTIONS ###

print_usage() {
	# Print script usage

	cat <<EOF
Usage: $0 --main DEVICE [-k KEYFILE] [OPTIONS]
Install the system on this machine.

    --main                  path to the device with the main disk
	-k, --keyfile           path to the age key file
EOF
}

### PARSE ARGUMENTS ###

main=''
keyfile="${SOPS_AGE_KEY_FILE:-${SOPS_AGE_KEY_DIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/sops/age}/keys.txt}"
unparsed=''

while [[ -n ${1:-} ]]; do
	case "$1" in
	--main)
		shift
		main="$1"
		;;
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

if [[ -z ${main} ]]; then
	printf '%s\n' 'Error: --main is required.' >&2
	print_usage >&2
	exit 1
fi

if [[ ! -e ${main} ]]; then
	printf '%s\n' "Error: Device ${main} does not exist." >&2
	print_usage >&2
	exit 2
fi

if [[ ! -e ${keyfile} ]]; then
	printf '%s\n' "Error: Key file ${keyfile} does not exist." >&2
	print_usage >&2
	exit 3
fi

### MAIN ###

disko-install \
	--flake "${FLAKE}#${HOST}" \
	--disk main "${main}" \
	--extra-files "${keyfile}" /var/lib/sops/age/keys.txt \
	--write-efi-boot-entries \
	"$@"
