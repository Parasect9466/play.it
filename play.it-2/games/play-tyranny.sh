#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
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
# Tyranny
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200302.1

# Set game-specific variables

GAME_ID='tyranny'
GAME_NAME='Tyranny'

ARCHIVE_GOG='tyranny_v1_2_1_160_v2_25169.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/tyranny_commander_edition'
ARCHIVE_GOG_MD5='72bdb7c9f6966ac6f1ccfbbad9fb29e6'
ARCHIVE_GOG_TYPE='mojosetup_unzip'
ARCHIVE_GOG_VERSION='1.2.1.160-gog25169'
ARCHIVE_GOG_SIZE='16000000'

ARCHIVE_GOG_OLD0='tyranny_en_1_2_1_0158_15398.sh'
ARCHIVE_GOG_OLD0_MD5='664cba00a861611fb155f65b8d83d9e9'
ARCHIVE_GOG_OLD0_TYPE='mojosetup_unzip'
ARCHIVE_GOG_OLD0_VERSION='1.2.1.0158-gog15398'
ARCHIVE_GOG_OLD0_SIZE='15000000'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='Tyranny.x86 Tyranny_Data/*/x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='Tyranny.x86_64 Tyranny_Data/*/x86_64'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN64_FILES_GOG_OLD0='Tyranny Tyranny_Data/*/x86_64'

ARCHIVE_GAME_AREAS_PATH='data/noarch/game'
ARCHIVE_GAME_AREAS_FILES='Tyranny_Data/bundles/st_ar_*'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Tyranny_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='Tyranny.x86'
APP_MAIN_EXE_BIN64='Tyranny.x86_64'
# shellcheck disable=SC2016
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='Tyranny_Data/Resources/UnityPlayer.png'
# Keep compatibility with old archives
APP_MAIN_EXE_BIN64_GOG_OLD0='Tyranny'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_AREAS PKG_DATA'

PKG_AREAS_ID="${GAME_ID}-areas"
PKG_AREAS_DESCRIPTION='areas'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_AREAS_ID $PKG_DATA_ID glibc libstdc++ glx libxrandr xcursor libudev1"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

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

# Get game icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Write launchers

use_archive_specific_value 'APP_MAIN_EXE_BIN64'
for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launcher_write 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
