#!/bin/sh

### CONFIGURATION ###

SHUF='@shuf@'
PRINTF='@printf@'
MKTEMP='@mktemp@'
CURL='@curl@'
JQ='@jq@'
TR='@tr@'
SED='@sed@'
AWK='@awk@'
KRABBY='@krabby@'
BASE64='@base64@'
RM='@rm@'

### FUNCTIONS ###

# Get random pokeapi id
get_random_pokeapi_id() {
	"${SHUF}" -i 1-905 -n 1
}

# Get pokeapi id
# $1: pokemon id or name (optional)
get_pokeapi_id() {
	if [ -n "${1}" ]; then
		"${PRINTF}" '%s' "${1}"
	else
		get_random_pokeapi_id
	fi
}

# Get temporare file
get_temporary_file() {
	"${MKTEMP}" "$@"
}

# Get temporary json file
get_temporary_json_file() {
	get_temporary_file --suffix '.json'
}

# Get pokemon data
# $1: pokeapi id
get_pokemon_data() {
	"${CURL}" -fsL https://pokeapi.co/api/v2/pokemon/"${1}"
}

# Get species data
# $1: species url
get_species_data() {
	"${CURL}" -fsL "${1}"
}

# Get species url
# $1: pokemon data file
get_species_url() {
	"${JQ}" -r '.species.url' <"${1}"
}

# Get species data
# $1: species url
get_species_data() {
	"${CURL}" -fsL "${1}"
}

# Get pokemon id
# $1: pokemon data file
get_pokemon_id() {
	"${JQ}" -r '.id' <"${1}"
}

# Get pokemon types
# $1: pokemon data file
get_pokemon_types() {
	"${JQ}" -r '.types[].type.name' <"${1}" |
		"${TR}" '\n' ' ' |
		"${SED}" 's/ *$//g'
}

# Get pokemon name
# $1: pokemon data file
get_pokemon_name() {
	"${JQ}" -r '.name' <"${1}"
}

# Get pokemon full name
# $1: species data file
get_pokemon_fullname() {
	"${JQ}" -r 'last(.names[] | select(.language.name == "en")).name' <"${1}"
}

# Get pokemon description
# $1: species data file
get_pokemon_description() {
	"${JQ}" -r 'last(.flavor_text_entries[] | select(.language.name == "en")).flavor_text' <"${1}" |
		"${TR}" '\n\f' ' ' |
		"${SED}" 's/ *$//g'
}

# Get shininess
get_shininess() {
	# shellcheck disable=SC2016
	shuf -i 1-100 -n 1 |
		"${AWK}" '{ if ($1 <= 5) print "true"; else print "false" }'
}

# Get pokemon image encoded in base64
# $1: pokemon name
# $2: is shiny
get_pokemon_image() {
	file="$(get_temporary_file)" || return 1

	if [ "${2}" = "true" ]; then
		"${KRABBY}" name "${1}" --no-title --shiny >"${file}" 2>/dev/null || return 2
	else
		"${KRABBY}" name "${1}" --no-title >"${file}" 2>/dev/null || return 2
	fi

	"${BASE64}" -w 0 <"${file}" || return 3

	remove_temporary_file "${file}" || return 4
}

# Remove temporary file
# $1: filename
remove_temporary_file() {
	"${RM}" -f "${1}"
}

# Execute
# $1: pokemon id or name (optional)
execute() {
	pokeapi_id="$(get_pokeapi_id "${1}")" || return 1

	pokemon_data_file="$(get_temporary_json_file)" || return 2
	get_pokemon_data "${pokeapi_id}" >"${pokemon_data_file}" || return 3

	species_url="$(get_species_url "${pokemon_data_file}")" || return 4
	species_data_file="$(get_temporary_json_file)" || return 5
	get_species_data "${species_url}" >"${species_data_file}" || return 6

	pokemon_id="$(get_pokemon_id "${pokemon_data_file}")" || return 7
	types="$(get_pokemon_types "${pokemon_data_file}")" || return 8
	name="$(get_pokemon_name "${pokemon_data_file}")" || return 9
	fullname="$(get_pokemon_fullname "${species_data_file}")" || return 10
	description="$(get_pokemon_description "${species_data_file}")" || return 11
	shiny="$(get_shininess)" || return 12
	image="$(get_pokemon_image "${name}" "${shiny}")" || return 13

	remove_temporary_file "${pokemon_data_file}" || return 14
	remove_temporary_file "${species_data_file}" || return 15

	# Print json
	"${PRINTF}" '{"pokemon_id": "%s", "types": "%s", "name": "%s", "fullname": "%s", "description": "%s", "shiny": "%s", "image": "%s"}\n' \
		"${pokemon_id}" \
		"${types}" \
		"${name}" \
		"${fullname}" \
		"${description}" \
		"${shiny}" \
		"${image}"
}

### MAIN ###

# Execute
execute "$@"
