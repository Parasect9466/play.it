#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2020, BetaRays
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# This software is provided by the copyright holders and contributors "as is"
# and any express or implied warranties, including, but not limited to, the
# implied warranties of merchantability and fitness for a particular purpose
# are disclaimed. In no event shall the copyright holder or contributors be
# liable for any direct, indirect, incidental, special, exemplary, or
# consequential damages (including, but not limited to, procurement of
# substitute goods or services; loss of use, data, or profits; or business
# interruption) however caused and on any theory of liability, whether in
# contract, strict liability, or tort (including negligence or otherwise)
# arising in any way out of the use of this software, even if advised of the
# possibility of such damage.
###

###
# CrossCode - Demo
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20200223.1

# Set game-specific variables

GAME_ID='crosscode-demo'
GAME_NAME='CrossCode - Demo'

ARCHIVES_LIST='ARCHIVE_CROSSCODE'

ARCHIVE_CROSSCODE='crosscode-demo.zip'
ARCHIVE_CROSSCODE_URL='https://www.cross-code.com/en/home'
ARCHIVE_CROSSCODE_MD5='22c54c8c415ecf056bd703dbed09c13d'
ARCHIVE_CROSSCODE_VERSION='0.7.1beta-crosscode'
ARCHIVE_CROSSCODE_SIZE='130000'
ARCHIVE_CROSSCODE_TYPE='zip'

ARCHIVE_DOC_WINE_PATH='.'
ARCHIVE_DOC_WINE_FILES='credits.html'

ARCHIVE_GAME_WINE_PATH='.'
ARCHIVE_GAME_WINE_FILES='crosscode-demo.exe nw.pak ffmpegsumo.dll icudt.dll'

APP_WINE_TYPE='wine'
APP_WINE_EXE='crosscode-demo.exe'
APP_WINE_ICON='favicon.png'

APP_MAIN_TYPE='native'
APP_MAIN_EXE='crosscode-web/node-webkit.html'
APP_MAIN_ICON='favicon.png'

PACKAGES_LIST='PKG_WINE PKG_MAIN'

# glx is here because it seems nw can use regular OpenGL when swiftshader isn't present

PKG_WINE_ID="${GAME_ID}-wine"
PKG_WINE_ARCH='32'
PKG_WINE_PROVIDE="${GAME_ID}"
PKG_WINE_DEPS='wine glx alsa'


PKG_MAIN_DEPS_DEB='firefox'
PKG_MAIN_DEPS_ARCH='firefox'
PKG_MAIN_DEPS_GENTOO='|| ( www-client/firefox www-client/firefox-bin )'

# Load common functions

target_version='2.11'

if [ -z "$PLAYIT_LIB2" ]; then
	: "${XDG_DATA_HOME:="$HOME/.local/share"}"
	for path in\
		"$PWD"\
		"$XDG_DATA_HOME/play.it"\
		'/usr/local/share/games/play.it'\
		'/usr/local/share/play.it'\
		'/usr/share/games/play.it'\
		'/usr/share/play.it'
	do
		if [ -e "$path/libplayit2.sh" ]; then
			PLAYIT_LIB2="$path/libplayit2.sh"
			break
		fi
	done
fi
if [ -z "$PLAYIT_LIB2" ]; then
	printf '\n\033[1;31mError:\033[0m\n'
	printf 'libplayit2.sh not found.\n'
	exit 1
fi
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"

exe_path="$PLAYIT_WORKDIR/gamedata/crosscode-demo.exe"
[ -d "$PLAYIT_WORKDIR/extraction" ] || mkdir "$PLAYIT_WORKDIR/extraction"
dd if="$exe_path" bs="$(unzip -l "$exe_path" 2>&1 1>/dev/null | grep --extended-regexp --only-matching '[0-9]+ extra bytes' | grep --extended-regexp --only-matching '^[0-9]+')" skip=1 of="$PLAYIT_WORKDIR/extraction/crosscode-demo_exe.zip" status=none

doc_dir="${PKG_MAIN_PATH}${PATH_DOC}/crosscode"
mkdir --parents "$doc_dir"
cp "$PLAYIT_WORKDIR/gamedata/credits.html" "$doc_dir/"

prepare_package_layout


rm --recursive "$PLAYIT_WORKDIR/gamedata"
extract_data_from "$PLAYIT_WORKDIR/extraction/crosscode-demo_exe.zip"

# Extract game icons

PKG='PKG_WINE'
icons_get_from_workdir 'APP_WINE'
PKG='PKG_MAIN'
icons_get_from_workdir 'APP_MAIN'

# Fix node-webkit.html to work with regular web browsers

pattern="/    \/\/ make sure we don't let node-webkit show it's error page/,+8d"
sed --regexp-extended --in-place --expression "$pattern" "$PLAYIT_WORKDIR/gamedata/node-webkit.html"

# Copy game "website" for main package

game_path="${PKG_MAIN_PATH}${PATH_GAME}"
mkdir --parents "$game_path/crosscode-web"
cp --recursive "$PLAYIT_WORKDIR/gamedata/"* "$game_path/crosscode-web"

rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_WINE'
launcher_write 'APP_WINE'
PKG='PKG_MAIN'
launcher_write 'APP_MAIN'

pattern='s/^".\/\$APP_EXE"/firefox --kiosk &/'
sed --regexp-extended --in-place --expression "$pattern" "$(get_value "${PKG}_PATH")/${PATH_BIN}/$GAME_ID"

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

#TODO: separate wine and main
print_instructions

exit 0
