#!/bin/bash

# satisfy shellcheck
stdenv=${stdenv:?}
srcs=${srcs:?}
out=${out:?}

# shellcheck disable=SC1091
source "${stdenv}/setup"

unpackPhase() {
	# just unpack the archives

	for src in ${srcs}; do
		# first make a temporary directory
		# extract the archive into it
		# and cd into that directory
		# the archive has a top-level directory with a name of the font,
		# but we don't know the name,
		# so we move all the files to the current directory by wildcard
		dir=$(mktemp -d -p .)
		7z x "${src}" -o"${dir}" -y
		cd "${dir}" || exit 1
		mv ./*/* .

		# now we have a single .pkg file (with unknown name)
		# extract it into a temporary directory and cd into it
		dir=$(mktemp -d -p .)
		7z x ./*.pkg -o"${dir}" -y
		cd "${dir}" || exit 1

		# lastly, we have a Payload~ file
		# as before, extract it into a temporary directory and cd into it
		dir=$(mktemp -d -p .)
		7z x 'Payload~' -o"${dir}" -y
		cd "${dir}" || exit 1

		# and at the end we should go back to the original directory
		cd ../../.. || exit 1

		# now the font files are in:
		# <tmpdir>/<tmpdir>/<tmpdir>/Library/Fonts/
	done
}

buildPhase() {
	# patch the mono font with nerd-fonts

	mkdir patched

	find . -type f -path '*/Library/Fonts/*Mono*.ttf' -exec nerd-font-patcher -c -out patched {} \;
	find . -type f -path '*/Library/Fonts/*Mono*.otf' -exec nerd-font-patcher -c -out patched {} \;
}

installPhase() {
	# copy the font files to the proper directories

	mkdir -p "${out}/share/fonts/truetype"
	mkdir -p "${out}/share/fonts/opentype"

	find . -type f -path '*/Library/Fonts/*.ttf' -exec mv {} "${out}/share/fonts/truetype" \;
	find . -type f -path '*/Library/Fonts/*.otf' -exec mv {} "${out}/share/fonts/opentype" \;

	find . -type f -path './patched/*.ttf' -exec mv {} "${out}/share/fonts/truetype" \;
	find . -type f -path './patched/*.otf' -exec mv {} "${out}/share/fonts/opentype" \;
}

genericBuild
