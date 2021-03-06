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
# Darkest Dungeon
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190520.5

# Set game-specific variables

GAME_ID='darkest-dungeon'
GAME_NAME='Darkest Dungeon'

ARCHIVE_GOG='darkest_dungeon_24839_28859.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/darkest_dungeon'
ARCHIVE_GOG_MD5='2a04beb04b3129b4bd68b4dd9023e82d'
ARCHIVE_GOG_SIZE='2300000'
ARCHIVE_GOG_VERSION='24839-gog28859'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD6='darkest_dungeon_24788_26004.sh'
ARCHIVE_GOG_OLD6_MD5='be838bdc8e7c971e4d412f833fd348ac'
ARCHIVE_GOG_OLD6_SIZE='2300000'
ARCHIVE_GOG_OLD6_VERSION='24788-gog26004'
ARCHIVE_GOG_OLD6_TYPE='mojosetup'

ARCHIVE_GOG_OLD5='darkest_dungeon_en_24358_23005.sh'
ARCHIVE_GOG_OLD5_MD5='3d7dc739665003d48589cdbe6cc472ef'
ARCHIVE_GOG_OLD5_SIZE='2300000'
ARCHIVE_GOG_OLD5_VERSION='24358-gog23005'
ARCHIVE_GOG_OLD5_TYPE='mojosetup'

ARCHIVE_GOG_OLD4='darkest_dungeon_en_24154_22522.sh'
ARCHIVE_GOG_OLD4_MD5='361d3e7b117725e8ce3982d183d4810a'
ARCHIVE_GOG_OLD4_SIZE='2300000'
ARCHIVE_GOG_OLD4_VERSION='24154-gog22522'
ARCHIVE_GOG_OLD4_TYPE='mojosetup'

ARCHIVE_GOG_OLD3='darkest_dungeon_en_23904_21681.sh'
ARCHIVE_GOG_OLD3_MD5='9ddb131060d0995c4ceb56dd9c846b8f'
ARCHIVE_GOG_OLD3_SIZE='2300000'
ARCHIVE_GOG_OLD3_VERSION='23904-gog21681'
ARCHIVE_GOG_OLD3_TYPE='mojosetup'

ARCHIVE_GOG_OLD2='darkest_dungeon_en_23885_21662.sh'
ARCHIVE_GOG_OLD2_MD5='ff449de9cfcdf97fa1a27d1073139463'
ARCHIVE_GOG_OLD2_SIZE='2300000'
ARCHIVE_GOG_OLD2_VERSION='23885-gog21662'
ARCHIVE_GOG_OLD2_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='darkest_dungeon_en_21142_16140.sh'
ARCHIVE_GOG_OLD1_MD5='4b43065624dbab74d794c56809170588'
ARCHIVE_GOG_OLD1_SIZE='2200000'
ARCHIVE_GOG_OLD1_VERSION='21142-gog16140'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='darkest_dungeon_en_21096_16066.sh'
ARCHIVE_GOG_OLD0_MD5='435905fe6edd911a8645d4feaf94ec34'
ARCHIVE_GOG_OLD0_SIZE='2200000'
ARCHIVE_GOG_OLD0_VERSION='21096-gog16066'
ARCHIVE_GOG_OLD0_TYPE='mojosetup'

DATA_DIRS='./logs'

ARCHIVE_DOC0_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC0_DATA_FILES='*'

ARCHIVE_DOC1_DATA_PATH='data/noarch/game'
ARCHIVE_DOC1_DATA_FILES='README.linux'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='lib darkest.bin.x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='lib64 darkest.bin.x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='audio video Icon.bmp pin svn_revision.txt activity_log campaign colours curios cursors dungeons effects fe_flow fonts fx game_over heroes inventory loading_screen loot maps modes mods monsters overlays panels props raid raid_results scripts scrolls shaders shared trinkets upgrades user_information localization/*.bat localization/*.csv localization/*.loc localization/*.txt localization/*.xml localization/pc'

APP_MAIN_TYPE='native'
APP_MAIN_EXE_BIN32='darkest.bin.x86'
APP_MAIN_EXE_BIN64='darkest.bin.x86_64'
APP_MAIN_ICON='Icon.bmp'

PACKAGES_LIST='PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++6 sdl2 glx"

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

# Get icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launchers_write 'APP_MAIN'
done

# Set up persistent logging

# shellcheck disable=SC2016
pattern='s|"\./$APP_EXE" $APP_OPTIONS $@|& 1>./logs/$(date +%F-%R).log 2>\&1|'
file0="${PKG_BIN32_PATH}${PATH_BIN}/$GAME_ID"
file1="${PKG_BIN64_PATH}${PATH_BIN}/$GAME_ID"
if [ $DRY_RUN -eq 0 ]; then
	sed --in-place "$pattern" "$file0" "$file1"
fi

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
