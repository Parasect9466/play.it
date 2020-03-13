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
# Monkey Island 2 Special Edition: LeChuck's Revenge
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20200313.1

# Set game-specific variables

GAME_ID='monkey-island-2-special-edition'
GAME_NAME="Monkey Island 2 Special Edition: LeChuck's Revenge"

ARCHIVE_GOG='setup_monkey_island2_se_2.0.0.10.exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/monkey_island_2_special_edition_lechucks_revenge'
ARCHIVE_GOG_TYPE='innosetup'
ARCHIVE_GOG_MD5='20a0bc39dcf543856f0d463649c482c4'
ARCHIVE_GOG_SIZE='2300000'
ARCHIVE_GOG_VERSION='1.0-gog2.0.0.10'

ARCHIVE_DOC_DATA_PATH='tmp'
ARCHIVE_DOC_DATA_FILES='eula*.txt'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='monkey2.pak audio ui language_setup.ini language_setup.png lang.ini'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='monkey2.exe language_setup.exe'

APP_WINE_LINK_DIRS='userdata:users/$(whoami)/Application Data/LucasArts/Monkey Island 2 Special Edition'

CONFIG_FILES='userdata/Settings.ini lang.ini'
DATA_FILES='monkey2.bin'

APP_WINETRICKS='xact d3dx9_42 d3dcompiler_42'

APP_REGEDIT='install.reg'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='monkey2.exe'
APP_MAIN_ICON='monkey2.exe'

APP_LANGUAGE_TYPE='wine'
APP_LANGUAGE_EXE='language_setup.exe'
APP_LANGUAGE_ID="${GAME_ID}_language"
APP_LANGUAGE_NAME="$GAME_NAME - Language setup"
APP_LANGUAGE_CAT='Settings'
APP_LANGUAGE_ICON='language_setup.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID wine"

# Load common functions

target_version='2.13'

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

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract game icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_LANGUAGE'
icons_move_to 'PKG_DATA'

# Register paths for APP_LANGUAGE

cat > "${PKG_BIN_PATH}${PATH_GAME}/install.reg" << EOF
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\\Software\\GOG.com\\Games\\1425039730]
"PATH"="C:\\\\$GAME_ID"
EOF

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_LANGUAGE'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
