#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2020, macaron
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
# Monkey Island 4: Escape from Monkey Island
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200314.3

# Set game-specific variables

GAME_ID='monkey-island-4'
GAME_NAME='Monkey Island 4: Escape from Monkey Island'

ARCHIVES_LIST='ARCHIVE_GOG_EN ARCHIVE_GOG_FR'

ARCHIVE_GOG_EN='setup_escape_from_monkey_islandtm_1.1_(20987).exe'
ARCHIVE_GOG_EN_URL='https://www.gog.com/game/escape_from_monkey_island'
ARCHIVE_GOG_EN_MD5='54978965b60294d5c1639b71c0a8159a'
ARCHIVE_GOG_EN_VERSION='1.1-gog20987'
ARCHIVE_GOG_EN_SIZE='1300000'
ARCHIVE_GOG_EN_PART1='setup_escape_from_monkey_islandtm_1.1_(20987)-1.bin'
ARCHIVE_GOG_EN_PART1_TYPE='innosetup'
ARCHIVE_GOG_EN_PART1_MD5='21bc4e362f73b76e6808649167ee9d20'

ARCHIVE_GOG_FR='setup_escape_from_monkey_islandtm_1.1_(french)_(20987).exe'
ARCHIVE_GOG_FR_URL='https://www.gog.com/game/escape_from_monkey_island'
ARCHIVE_GOG_FR_MD5='5ca039d42d53ad7fe206b289abe15deb'
ARCHIVE_GOG_FR_VERSION='1.1-gog20987'
ARCHIVE_GOG_FR_SIZE='1300000'
ARCHIVE_GOG_FR_PART1='setup_escape_from_monkey_islandtm_1.1_(french)_(20987)-1.bin'
ARCHIVE_GOG_FR_PART1_TYPE='innosetup'
ARCHIVE_GOG_FR_PART1_MD5='c5bf233f09cca2a8e33d78d25cf58329'

ARCHIVE_RESIDUALVM_PATCH_EN='MonkeyUpdate.exe'
ARCHIVE_RESIDUALVM_PATCH_EN_URL='https://demos.residualvm.org/patches/'
ARCHIVE_RESIDUALVM_PATCH_EN_MD5='7c7dbd2349d49e382a2dea40bed448e0'
ARCHIVE_RESIDUALVM_PATCH_EN_TYPE='file'

ARCHIVE_RESIDUALVM_PATCH_FR='MonkeyUpdate_FRA.exe'
ARCHIVE_RESIDUALVM_PATCH_FR_URL='https://demos.residualvm.org/patches/'
ARCHIVE_RESIDUALVM_PATCH_FR_MD5='cc5ff3bb8f78a0eb4b8e0feb9cdd2e87'
ARCHIVE_RESIDUALVM_PATCH_FR_TYPE='file'

ARCHIVE_DOC_DATA_PATH='.'
ARCHIVE_DOC_DATA_FILES='*.pdf *.txt'

ARCHIVE_GAME0_BIN_WINE_PATH='.'
ARCHIVE_GAME0_BIN_WINE_FILES='install *.asi *.dll *.exe *.flt'

ARCHIVE_GAME1_BIN_WINE_PATH='__support/save'
ARCHIVE_GAME1_BIN_WINE_FILES='saves'

ARCHIVE_GAME_BIN_RESIDUALVM_PATH='.'
ARCHIVE_GAME_BIN_RESIDUALVM_FILES='MonkeyUpdate*.exe'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='movies textures *.m4b'

CONFIG_FILES='saves/efmi.cfg'
DATA_FILES='saves/efmi*.gsv'

APP_REGEDIT='install.reg'

APP_MAIN_TYPE_BIN_WINE='wine'
APP_MAIN_TYPE_BIN_RESIDUALVM='residualvm'
APP_MAIN_EXE='monkey4.exe'
APP_MAIN_RESIDUALID='monkey4'
APP_MAIN_ICON='monkey4.exe'

PACKAGES_LIST='PKG_BIN_WINE PKG_BIN_RESIDUALVM PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_ID_GOG_EN="${PKG_DATA_ID}-en"
PKG_DATA_ID_GOG_FR="${PKG_DATA_ID}-fr"
PKG_DATA_PROVIDE="$PKG_DATA_ID"
PKG_DATA_DESCRIPTION='data'
PKG_DATA_DESCRIPTION_GOG_EN="$PKG_DATA_DESCRIPTION - English version"
PKG_DATA_DESCRIPTION_GOG_FR="$PKG_DATA_DESCRIPTION - French version"

PKG_BIN_ID="$GAME_ID"

PKG_BIN_WINE_ID="${PKG_BIN_ID}-wine"
PKG_BIN_WINE_ARCH='32'
PKG_BIN_WINE_ID_GOG_EN="${PKG_BIN_WINE_ID}-en"
PKG_BIN_WINE_ID_GOG_FR="${PKG_BIN_WINE_ID}-fr"
PKG_BIN_WINE_PROVIDE="$PKG_BIN_ID"
PKG_BIN_WINE_DEPS_GOG_EN="${PKG_DATA_ID}-en wine"
PKG_BIN_WINE_DEPS_GOG_FR="${PKG_DATA_ID}-fr wine"
PKG_BIN_WINE_DESCRIPTION_GOG_EN='English version'
PKG_BIN_WINE_DESCRIPTION_GOG_FR='French version'

PKG_BIN_RESIDUALVM_ID="${PKG_BIN_ID}-residualvm"
PKG_BIN_RESIDUALVM_PROVIDE="$PKG_BIN_ID"
PKG_BIN_RESIDUALVM_DEPS="$PKG_DATA_ID residualvm"

# Load common functions

target_version='2.12'

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
# shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Check presence of patch required by ResidualVM

ARCHIVE_MAIN="$ARCHIVE"
case "$ARCHIVE_MAIN" in
	('ARCHIVE_GOG_EN')
		ARCHIVE_PATCH='ARCHIVE_RESIDUALVM_PATCH_EN'
	;;
	('ARCHIVE_GOG_FR')
		ARCHIVE_PATCH='ARCHIVE_RESIDUALVM_PATCH_FR'
	;;
esac
archive_set 'ARCHIVE_RESIDUALVM_PATCH' "$ARCHIVE_PATCH"
if [ -z "$ARCHIVE_RESIDUALVM_PATCH" ]; then
	PACKAGES_LIST='PKG_BIN_WINE PKG_DATA'
fi
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
if [ -n "$ARCHIVE_RESIDUALVM_PATCH" ]; then
	cp "$ARCHIVE_RESIDUALVM_PATCH" "$PLAYIT_WORKDIR/gamedata"
	prepare_package_layout 'PKG_BIN_RESIDUALVM'
fi
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icons

PKG='PKG_BIN_WINE'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Register install path

cat > "${PKG_BIN_WINE_PATH}${PATH_GAME}/install.reg" << EOF
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\\Software\\LucasArts Entertainment Company LLC\\Monkey4\\Retail]
"Install Path"="C:\\\\$GAME_ID"
EOF

# Write launchers

PKG='PKG_BIN_WINE'
use_package_specific_value 'APP_MAIN_TYPE'
launchers_write 'APP_MAIN'

if [ -n "$ARCHIVE_RESIDUALVM_PATCH" ]; then
	PKG='PKG_BIN_RESIDUALVM'
	use_package_specific_value 'APP_MAIN_TYPE'
	launchers_write 'APP_MAIN'
fi

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

printf '\n'
if [ -n "$ARCHIVE_RESIDUALVM_PATCH" ]; then
	printf 'ResidualVM:'
	print_instructions 'PKG_DATA' 'PKG_BIN_RESIDUALVM'
fi
printf 'WINE:'
print_instructions 'PKG_DATA' 'PKG_BIN_WINE'

exit 0
