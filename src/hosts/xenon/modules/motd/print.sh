#!/usr/bin/env bash

### CONFIGURATION ###

SCRIPT='@script@'

### FUNCTIONS ###

# Get temporary json file
get_temporary_json_file() {
	mktemp --suffix '.json'
}

# Get data
get_data() {
	"${SCRIPT}" "$@"
}

# Get pokeapi id
# $1: data file
get_pokeapi_id() {
	jq --raw-output '.pokeapi_id' <"${1}"
}

# Get pokemon id
# $1: data file
get_pokemon_id() {
	jq --raw-output '.pokemon_id' <"${1}"
}

# Get pokemon types
# $1: data file
get_types() {
	jq --raw-output '.types' <"${1}"
}

# Get pokemon name
# $1: data file
get_name() {
	jq --raw-output '.name' <"${1}"
}

# Get pokemon full name
# $1: data file
get_fullname() {
	jq --raw-output '.fullname' <"${1}"
}

# Get pokemon description
# $1: data file
get_description() {
	jq --raw-output '.description' <"${1}"
}

# Get shininess
# $1: data file
get_shininess() {
	jq --raw-output '.shiny' <"${1}"
}

# Get pokemon image
# $1: data file
get_image() {
	# shellcheck disable=SC2312
	jq --raw-output '.image' <"${1}" |
		base64 --decode
}

# Get shiny color
get_shiny_color() {
	printf '%s' '#FFD700'
}

# Get type color
# $1: type
get_type_color() {
	case "${1}" in
	normal)
		printf '%s' '#A8A878'
		;;
	fire)
		printf '%s' '#F08030'
		;;
	fighting)
		printf '%s' '#C03028'
		;;
	water)
		printf '%s' '#6890F0'
		;;
	flying)
		printf '%s' '#A890F0'
		;;
	grass)
		printf '%s' '#78C850'
		;;
	poison)
		printf '%s' '#A040A0'
		;;
	electric)
		printf '%s' '#F8D030'
		;;
	ground)
		printf '%s' '#E0C068'
		;;
	psychic)
		printf '%s' '#F85888'
		;;
	rock)
		printf '%s' '#B8A038'
		;;
	ice)
		printf '%s' '#98D8D8'
		;;
	bug)
		printf '%s' '#A8B820'
		;;
	dragon)
		printf '%s' '#7038F8'
		;;
	ghost)
		printf '%s' '#705898'
		;;
	dark)
		printf '%s' '#705848'
		;;
	steel)
		printf '%s' '#B8B8D0'
		;;
	fairy)
		printf '%s' '#EE99AC'
		;;
	*)
		printf '%s' '#68A090'
		;;
	esac
}

# Print image
# $1: image
print_image() {
	gum style \
		-- \
		"${1}"
}

# Print pokemon id
# $1: pokemon id
print_pokemon_id() {
	gum style \
		--foreground '#000' \
		--background '#fff' \
		--padding '0 1' \
		-- \
		"No. ${1}"
}

# Print fullname
# $1: fullname
# $2: shininess
print_fullname() {
	if [[ ${2} == "true" ]]; then
		color="$(get_shiny_color)"
	else
		color='#fff'
	fi

	gum style \
		--bold \
		--padding '0 3' \
		--foreground "${color}" \
		-- \
		"${1}"
}

# Print type
# $1: type
print_type() {
	type="$(printf '%s' "${1}" | tr '[:lower:]' '[:upper:]')"
	color="$(get_type_color "${1}")"

	gum style \
		--foreground '#fff' \
		--background "${color}" \
		--padding '0 1' \
		-- \
		"${type}"
}

# Print types
# $1: types
print_types() {
	for type in ${1}; do
		# shellcheck disable=SC2312
		type="$(print_type "${type}")"
		printf '%s\0' "${type}"
	done |
		xargs -0 -- \
			gum join \
			--horizontal
}

# Print description
# $1: description
# $2: shininess
print_description() {
	if [[ ${2} == "true" ]]; then
		color="$(get_shiny_color)"
	else
		color='#fff'
	fi

	gum style \
		--border rounded \
		--border-foreground "${color}" \
		--foreground "${color}" \
		--width 50 \
		--padding 1 \
		--align center \
		-- \
		"${1}"
}

# Print info
# $1: pokeapi id
# $2: pokemon id
# $3: types
# $4: name
# $5: fullname
# $6: description
# $7: shininess
print_info() {
	pokemon_id="$(print_pokemon_id "${2}")"
	name="$(print_fullname "${5}" "${7}")"
	types="$(print_types "${3}")"
	description="$(print_description "${6}" "${7}")"

	top=$(
		gum join \
			--horizontal \
			-- \
			"${pokemon_id}" \
			"${name}" \
			"${types}"
	)
	top=$(gum style --padding '0 0 1 0' -- "${top}")

	gum join \
		--vertical \
		--align center \
		-- \
		"${top}" \
		"${description}"
}

# Remove temporary file
# $1: filename
remove_temporary_file() {
	rm --force "${1}"
}

# Print all
# $1: pokeapi id
# $2: pokemon id
# $3: types
# $4: name
# $5: fullname
# $6: description
# $7: shininess
# $8: image
print_all() {
	image="$(print_image "${8}")"
	info="$(print_info "${1}" "${2}" "${3}" "${4}" "${5}" "${6}" "${7}")"

	image=$(gum style --padding '0' -- "${image}")
	info=$(gum style --padding '0 0 0 6' -- "${info}")

	all=$(
		gum join \
			--horizontal \
			--align center \
			-- \
			"${image}" \
			"${info}"
	)

	gum style --padding 1 -- "${all}"
}

# Execute
execute() {
	file="$(get_temporary_json_file)" || return 1
	get_data "$@" >"${file}" || return 2

	pokeapi_id="$(get_pokeapi_id "${file}")" || return 3
	pokemon_id="$(get_pokemon_id "${file}")" || return 4
	types="$(get_types "${file}")" || return 5
	name="$(get_name "${file}")" || return 6
	fullname="$(get_fullname "${file}")" || return 7
	description="$(get_description "${file}")" || return 8
	shiny="$(get_shininess "${file}")" || return 9
	image="$(get_image "${file}")" || return 10

	remove_temporary_file "${file}" || return 11

	# Print all
	print_all "${pokeapi_id}" "${pokemon_id}" "${types}" "${name}" "${fullname}" "${description}" "${shiny}" "${image}"
}

### MAIN ###

# Execute
execute "$@"
