#!/bin/sh

### CONFIGURATION ###

CAT='@cat@'
MKTEMP='@mktemp@'
MOTDFILE='@motdfile@'
RM='@rm@'
SCRIPT='@script@'

### FUNCTIONS ###

# Get temporary file
get_temporary_file() {
	"${MKTEMP}"
}

# Print motd
print_motd() {
	"${SCRIPT}" "$@"
}

# Move file contents
# $1: source
# $2: destination
move_file_contents() {
	"${CAT}" "${1}" >"${2}"
}

# Remove temporary file
# $1: file
remove_temporary_file() {
	"${RM}" --force "${1}"
}

# Execute
execute() {
	file="$(get_temporary_file)"
	print_motd "$@" >"${file}" || return 1
	move_file_contents "${file}" "${MOTDFILE}" || return 2
	remove_temporary_file "${file}" || return 3
}

### MAIN ###

execute "$@"
