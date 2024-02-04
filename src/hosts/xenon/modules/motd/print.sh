#!/bin/sh

### CONFIGURATION ###

BASE64='@base64@'
GUM='@gum@'
JQ='@jq@'
MKTEMP='@mktemp@'
PRINTF='@printf@'
RM='@rm@'
SCRIPT='@script@'
TR='@tr@'
XARGS='@xargs@'

### FUNCTIONS ###

# Get temporary json file
get_temporary_json_file() {
	"${MKTEMP}" --suffix '.json'
}

# Get data
get_data() {
	"${SCRIPT}" "$@"
}

# Get pokeapi id
# $1: data file
get_pokeapi_id() {
	"${JQ}" --raw-output '.pokeapi_id' <"${1}"
}

# Get pokemon id
# $1: data file
get_pokemon_id() {
	"${JQ}" --raw-output '.pokemon_id' <"${1}"
}

# Get pokemon types
# $1: data file
get_types() {
	"${JQ}" --raw-output '.types' <"${1}"
}

# Get pokemon name
# $1: data file
get_name() {
	"${JQ}" --raw-output '.name' <"${1}"
}

# Get pokemon full name
# $1: data file
get_fullname() {
	"${JQ}" --raw-output '.fullname' <"${1}"
}

# Get pokemon description
# $1: data file
get_description() {
	"${JQ}" --raw-output '.description' <"${1}"
}

# Get shininess
# $1: data file
get_shininess() {
	"${JQ}" --raw-output '.shiny' <"${1}"
}

# Get pokemon image
# $1: data file
get_image() {
	"${JQ}" --raw-output '.image' <"${1}" |
		"${BASE64}" --decode
}

# Get shiny color
get_shiny_color() {
	"${PRINTF}" '%s' '#FFD700'
}

# Get type color
# $1: type
get_type_color() {
	case "${1}" in
	normal)
		"${PRINTF}" '%s' '#A8A878'
		;;
	fire)
		"${PRINTF}" '%s' '#F08030'
		;;
	fighting)
		"${PRINTF}" '%s' '#C03028'
		;;
	water)
		"${PRINTF}" '%s' '#6890F0'
		;;
	flying)
		"${PRINTF}" '%s' '#A890F0'
		;;
	grass)
		"${PRINTF}" '%s' '#78C850'
		;;
	poison)
		"${PRINTF}" '%s' '#A040A0'
		;;
	electric)
		"${PRINTF}" '%s' '#F8D030'
		;;
	ground)
		"${PRINTF}" '%s' '#E0C068'
		;;
	psychic)
		"${PRINTF}" '%s' '#F85888'
		;;
	rock)
		"${PRINTF}" '%s' '#B8A038'
		;;
	ice)
		"${PRINTF}" '%s' '#98D8D8'
		;;
	bug)
		"${PRINTF}" '%s' '#A8B820'
		;;
	dragon)
		"${PRINTF}" '%s' '#7038F8'
		;;
	ghost)
		"${PRINTF}" '%s' '#705898'
		;;
	dark)
		"${PRINTF}" '%s' '#705848'
		;;
	steel)
		"${PRINTF}" '%s' '#B8B8D0'
		;;
	fairy)
		"${PRINTF}" '%s' '#EE99AC'
		;;
	*)
		"${PRINTF}" '%s' '#68A090'
		;;
	esac
}

# Print image
# $1: image
print_image() {
	"${GUM}" style \
		-- \
		"${1}"
}

# Print pokemon id
# $1: pokemon id
print_pokemon_id() {
	"${GUM}" style \
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
	if [ "${2}" = "true" ]; then
		color="$(get_shiny_color)"
	else
		color='#fff'
	fi

	"${GUM}" style \
		--bold \
		--padding '0 3' \
		--foreground "${color}" \
		-- \
		"${1}"
}

# Print type
# $1: type
print_type() {
	type="$("${PRINTF}" '%s' "${1}" | "${TR}" '[:lower:]' '[:upper:]')"
	color="$(get_type_color "${1}")"

	"${GUM}" style \
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
		type="$(print_type "${type}")"
		"${PRINTF}" '%s\0' "${type}"
	done |
		"${XARGS}" -0 -- \
			"${GUM}" join \
			--horizontal
}

# Print description
# $1: description
# $2: shininess
print_description() {
	if [ "${2}" = "true" ]; then
		color="$(get_shiny_color)"
	else
		color='#fff'
	fi

	"${GUM}" style \
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
		"${GUM}" join \
			--horizontal \
			-- \
			"${pokemon_id}" \
			"${name}" \
			"${types}"
	)
	top=$("${GUM}" style --padding '0 0 1 0' -- "${top}")

	"${GUM}" join \
		--vertical \
		--align center \
		-- \
		"${top}" \
		"${description}"
}

# Remove temporary file
# $1: filename
remove_temporary_file() {
	"${RM}" --force "${1}"
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

	image=$("${GUM}" style --padding '0' -- "${image}")
	info=$("${GUM}" style --padding '0 0 0 6' -- "${info}")

	all=$(
		"${GUM}" join \
			--horizontal \
			--align center \
			-- \
			"${image}" \
			"${info}"
	)

	"${GUM}" style --padding 1 -- "${all}"
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
