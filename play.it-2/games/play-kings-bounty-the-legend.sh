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
# King’s Bounty: The Legend
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200229.1

# Set game-specific variables

GAME_ID='kings-bounty-the-legend'
GAME_NAME='Kingʼs Bounty: The Legend'

ARCHIVES_LIST='ARCHIVE_GOG_EN ARCHIVE_GOG_FR'

ARCHIVE_GOG_EN='setup_kings_bounty_the_legend_1.7_(15542).exe'
ARCHIVE_GOG_EN_URL='https://www.gog.com/game/kings_bounty_the_legend'
ARCHIVE_GOG_EN_MD5='f7a9defe0fd96a7f8d6dff6ed7828242'
ARCHIVE_GOG_EN_VERSION='1.7-gog15542'
ARCHIVE_GOG_EN_SIZE='6000000'
ARCHIVE_GOG_EN_PART1='setup_kings_bounty_the_legend_1.7_(15542)-1.bin'
ARCHIVE_GOG_EN_PART1_MD5='04fb818107e4bfe7aeae449778e88dd9'
ARCHIVE_GOG_EN_PART1_TYPE='innosetup'

ARCHIVE_GOG_FR='setup_kings_bounty_the_legend_french_1.7_(15542).exe'
ARCHIVE_GOG_FR_URL='https://www.gog.com/game/kings_bounty_the_legend'
ARCHIVE_GOG_FR_MD5='646fdfacadc498826be127fe6703f259'
ARCHIVE_GOG_FR_VERSION='1.7-gog15542'
ARCHIVE_GOG_FR_SIZE='6000000'
ARCHIVE_GOG_FR_PART1='setup_kings_bounty_the_legend_french_1.7_(15542)-1.bin'
ARCHIVE_GOG_FR_PART1_MD5='907882679fb7050e172994d36730454a'
ARCHIVE_GOG_FR_PART1_TYPE='innosetup'

ARCHIVE_DOC_L10N_PATH='app'
ARCHIVE_DOC_L10N_FILES='readme.rtf manual.pdf'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*.dll kb.exe data/default.ini data/game.ini data/fonts.cfg'

ARCHIVE_GAME_L10N_PATH='app'
ARCHIVE_GAME_L10N_FILES='data/app.ini data/loc_data.kfs sessions/base/loc_ses.kfs'

ARCHIVE_GAME_DATA_PATH='app'
ARCHIVE_GAME_DATA_FILES='curver.txt data sessions'

CONFIG_FILES='./data/*.ini ./data/fonts.cfg'

APP_WINETRICKS='d3dx9'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='kb.exe'
APP_MAIN_ICON='kb.exe'

PACKAGES_LIST='PKG_BIN PKG_L10N PKG_DATA'

PKG_L10N_ID="${GAME_ID}-l10n"
PKG_L10N_ID_GOG_EN="${PKG_L10N_ID}-en"
PKG_L10N_ID_GOG_FR="${PKG_L10N_ID}-fr"
PKG_L10N_PROVIDE="$PKG_L10N_ID"
PKG_L10N_DESCRIPTION_GOG_EN='English localization'
PKG_L10N_DESCRIPTION_GOG_FR='French localization'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_L10N_ID $PKG_DATA_ID wine"

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

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN'
icons_move_to 'PKG_DATA'

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
