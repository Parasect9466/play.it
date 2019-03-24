#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine Le Gonidec
# Copyright (c) 2018-2019, Solène Huault
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
# RiME
# build native packages from the original installers
# send your bug reports to mopi@dotslashplay.it
###

script_version=20190220.2

# Set game-specific variables

GAME_ID='rime'
GAME_NAME='RiME'

ARCHIVE_GOG='setup_rime_152498_signed_(14865).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/rime'
ARCHIVE_GOG_MD5='303d41314564c753fcef92260c3e20f8'
ARCHIVE_GOG_VERSION='1.04-gog14865'
ARCHIVE_GOG_SIZE='8000000'
ARCHIVE_GOG_PART1='setup_rime_152498_signed_(14865)-1.bin'
ARCHIVE_GOG_PART1_MD5='ea9fc9eeaeeb2d7c58eab42cef31bb2e'
ARCHIVE_GOG_PART1_TYPE='innosetup'
ARCHIVE_GOG_PART2='setup_rime_152498_signed_(14865)-2.bin'
ARCHIVE_GOG_PART2_MD5='b65792a122d267cc799e9b044605c1a1'
ARCHIVE_GOG_PART2_TYPE='innosetup'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='language_setup.exe rimelauncher.exe engine sirengame/binaries'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='language_setup.png sirengame/content'

DATA_DIRS='./saves'
CONFIG_DIRS='./config'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='sirengame/binaries/win64/rime.exe'
APP_MAIN_ICON='sirengame/binaries/win64/rime.exe'
APP_MAIN_ICON_ID='101'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID wine-staging"

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
# shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN'
launcher_write 'APP_MAIN'

# Store saved games outside of WINE prefix

# shellcheck disable=SC2016
saves_path='$WINEPREFIX/drive_c/users/$(whoami)/Local Settings/Application Data/SirenGame/Saved/SaveGames'
# shellcheck disable=SC2016
pattern='s#init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"#&'
pattern="$pattern\\nif [ ! -e \"$saves_path\" ]; then"
pattern="$pattern\\n\\tmkdir --parents \"${saves_path%/*}\""
pattern="$pattern\\n\\tln --symbolic \"\$PATH_DATA/saves\" \"$saves_path\""
pattern="$pattern\\nfi#"
sed --in-place "$pattern" "${PKG_BIN_PATH}${PATH_BIN}"/*

# Store configuration outside of WINE prefix

# shellcheck disable=SC2016
config_path='$WINEPREFIX/drive_c/users/$(whoami)/Local Settings/Application Data/SirenGame/Saved/Config/WindowsNoEditor'
# shellcheck disable=SC2016
pattern='s#init_prefix_dirs "$PATH_CONFIG" "$CONFIG_DIRS"#&'
pattern="$pattern\\nif [ ! -e \"$config_path\" ]; then"
pattern="$pattern\\n\\tmkdir --parents \"${config_path%/*}\""
pattern="$pattern\\n\\tln --symbolic \"\$PATH_CONFIG/config\" \"$config_path\""
pattern="$pattern\\nfi#"
sed --in-place "$pattern" "${PKG_BIN_PATH}${PATH_BIN}"/*

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
