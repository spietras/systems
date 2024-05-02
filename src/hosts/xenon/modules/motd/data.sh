#!/usr/bin/env bash

### FUNCTIONS ###

# Get random pokeapi id
get_random_pokeapi_id() {
	shuf --input-range 1-905 --head-count 1
}

# Get pokeapi id
# $1: pokemon id or name (optional)
get_pokeapi_id() {
	if [[ -n ${1:-} ]]; then
		printf '%s' "${1}"
	else
		get_random_pokeapi_id
	fi
}

# Get temporare file
get_temporary_file() {
	mktemp "$@"
}

# Get temporary json file
get_temporary_json_file() {
	get_temporary_file --suffix '.json'
}

# Get pokemon data
# $1: pokeapi id
get_pokemon_data() {
	curl --fail --silent --location https://pokeapi.co/api/v2/pokemon/"${1}"
}

# Get species url
# $1: pokemon data file
get_species_url() {
	jq --raw-output '.species.url' <"${1}"
}

# Get species data
# $1: species url
get_species_data() {
	curl --fail --silent --location "${1}"
}

# Get pokemon id
# $1: pokemon data file
get_pokemon_id() {
	jq --raw-output '.id' <"${1}"
}

# Get pokemon types
# $1: pokemon data file
get_pokemon_types() {
	# shellcheck disable=SC2312
	jq --raw-output '.types[].type.name' <"${1}" |
		tr '\n' ' ' |
		sed 's/ *$//g'
}

# Get pokemon name
# $1: pokemon data file
get_pokemon_name() {
	jq --raw-output '.name' <"${1}"
}

# Get pokemon full name
# $1: species data file
get_pokemon_fullname() {
	jq --raw-output 'last(.names[] | select(.language.name == "en")).name' <"${1}"
}

# Get pokemon description
# $1: species data file
get_pokemon_description() {
	# shellcheck disable=SC2312
	jq --raw-output 'last(.flavor_text_entries[] | select(.language.name == "en")).flavor_text' <"${1}" |
		tr '\n\f' ' ' |
		sed 's/ *$//g'
}

# Get shininess
get_shininess() {
	# shellcheck disable=SC2016,SC2312
	shuf --input-range 1-100 --head-count 1 |
		awk '{ if ($1 <= 5) print "true"; else print "false" }'
}

# Get pokemon image encoded in base64
# $1: pokemon name
# $2: is shiny
get_pokemon_image() {
	file="$(get_temporary_file)" || return 1

	if [[ ${2} == "true" ]]; then
		krabby name "${1}" --no-title --shiny >"${file}" 2>/dev/null || return 2
	else
		krabby name "${1}" --no-title >"${file}" 2>/dev/null || return 2
	fi

	base64 --wrap 0 <"${file}" || return 3

	remove_temporary_file "${file}" || return 4
}

# Remove temporary file
# $1: filename
remove_temporary_file() {
	rm --force "${1}"
}

# Execute
# $1: pokemon id or name (optional)
execute() {
	pokeapi_id="$(get_pokeapi_id "${1:-}")" || return 1

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
	printf '{"pokemon_id": "%s", "types": "%s", "name": "%s", "fullname": "%s", "description": "%s", "shiny": "%s", "image": "%s"}\n' \
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
