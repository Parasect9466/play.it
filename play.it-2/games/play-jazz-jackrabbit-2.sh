#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine Le Gonidec
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
# Jazz Jackrabbit 2
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200205.2

# Set game-specific variables

GAME_ID='jazz-jackrabbit-2'
GAME_NAME='Jazz Jackrabbit 2'

GAME_ID_SECRETFILES="${GAME_ID}-the-secret-files"
GAME_NAME_SECRETFILES="$GAME_NAME - The Secret Files"

GAME_ID_CHRISTMASCHRONICLES="${GAME_ID}-the-christmas-chronicles"
GAME_NAME_CHRISTMASCHRONICLES="$GAME_NAME - The Christmas Chronicles"

ARCHIVES_LIST='ARCHIVE_SECRETFILES_GOG ARCHIVE_CHRISTMASCHRONICLES_GOG'

ARCHIVE_SECRETFILES_GOG='setup_jazz_jackrabbit_2_1.24hf_(16886).exe'
ARCHIVE_SECRETFILES_GOG_URL='https://www.gog.com/game/jazz_jackrabbit_2_collection'
ARCHIVE_SECRETFILES_GOG_MD5='48a48258ed60b24068cbbb2f110b049b'
ARCHIVE_SECRETFILES_GOG_VERSION='1.24hf-gog16886'
ARCHIVE_SECRETFILES_GOG_SIZE='67000'

ARCHIVE_CHRISTMASCHRONICLES_GOG='setup_jazz_jackrabbit_2_cc_1.2x_(16742).exe'
ARCHIVE_CHRISTMASCHRONICLES_GOG_URL='https://www.gog.com/game/jazz_jackrabbit_2_collection'
ARCHIVE_CHRISTMASCHRONICLES_GOG_MD5='3289263ea6bad8bc35f02176e22109f2'
ARCHIVE_CHRISTMASCHRONICLES_GOG_VERSION='1.2x-gog16742'
ARCHIVE_CHRISTMASCHRONICLES_GOG_SIZE='70000'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='*.pdf *.txt'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*.exe *.ini'

ARCHIVE_GAME0_DATA_PATH='app'
ARCHIVE_GAME0_DATA_FILES='html jcshelp tiles userlevels *.it *.j2? *.mod *.s3m'

ARCHIVE_GAME1_DATA_PATH='app/__support'
ARCHIVE_GAME1_DATA_FILES='save'

CONFIG_FILES='./*.ini ./*.CFG'
DATA_DIRS='./save'
DATA_FILES='./*.log'

APP_MAIN_TYPE='wine'
APP_MAIN_EXE='jazz2.exe'
APP_MAIN_ICON='jazz2.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID_SECRETFILES="${GAME_ID_SECRETFILES}-data"
PKG_DATA_ID_CHRISTMASCHRONICLES="${GAME_ID_CHRISTMASCHRONICLES}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS='wine'

PKG_BIN_ID_SECRETFILES="$GAME_ID_SECRETFILES"
PKG_BIN_DEPS_SECRETFILES="$PKG_DATA_ID_SECRETFILES $PKG_BIN_DEPS"

PKG_BIN_ID_CHRISTMASCHRONICLES="$GAME_ID_CHRISTMASCHRONICLES"
PKG_BIN_DEPS_CHRISTMASCHRONICLES="$PKG_DATA_ID_CHRISTMASCHRONICLES $PKG_BIN_DEPS"

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

# Set game info based on source archive

use_archive_specific_value 'GAME_ID'
use_archive_specific_value 'GAME_NAME'
case $OPTION_PACKAGE in
	('arch'|'gentoo')
		PATH_DOC="$OPTION_PREFIX/share/doc/$GAME_ID"
		PATH_GAME="$OPTION_PREFIX/share/$GAME_ID"
	;;
	('deb')
		PATH_DOC="$OPTION_PREFIX/share/doc/$GAME_ID"
		PATH_GAME="$OPTION_PREFIX/share/games/$GAME_ID"
	;;
	(*)
		liberror 'OPTION_PACKAGE' "$0"
	;;
esac
set_temp_directories $PACKAGES_LIST

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
