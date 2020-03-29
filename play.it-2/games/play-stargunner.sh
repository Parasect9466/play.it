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
# Stargunner
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200329.1

# Set game-specific variables

GAME_ID='stargunner'
GAME_NAME='Stargunner'

ARCHIVE_GOG='gog_stargunner_2.0.0.10.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/stargunner'
ARCHIVE_GOG_MD5='d04655b120bce07d7c840f49e89e6a83'
ARCHIVE_GOG_VERSION='1.0-gog2.0.0.10'
ARCHIVE_GOG_SIZE='58000'

ARCHIVE_GOG_OLD0='gog_stargunner_2.0.0.9.sh'
ARCHIVE_GOG_OLD0_MD5='4e90175d15754e05ad6cb0a0fa1af413'
ARCHIVE_GOG_OLD0_VERSION='1.0-gog2.0.0.9'
ARCHIVE_GOG_OLD0_SIZE='57000'

ARCHIVE_DOC_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC_MAIN_FILES='*.pdf'

ARCHIVE_GAME_MAIN_PATH='data/noarch/data'
ARCHIVE_GAME_MAIN_FILES='*'

CONFIG_FILES='./STARGUN.CFG'
DATA_FILES='./STARGUN.HI ./STARGUN.SAV'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='STARGUN.EXE'
APP_MAIN_ICON='data/noarch/support/icon.png'

APP_HELP_ID="${GAME_ID}_help"
APP_HELP_NAME="$GAME_NAME - help"
APP_HELP_TYPE='dosbox'
APP_HELP_EXE='STARHELP.EXE'
APP_HELP_ICON="$APP_MAIN_ICON"

APP_SETUP_ID="${GAME_ID}_setup"
APP_SETUP_NAME="$GAME_NAME - setup"
APP_SETUP_CAT='Settings'
APP_SETUP_TYPE='dosbox'
APP_SETUP_EXE='SETUP.EXE'
APP_SETUP_ICON="$APP_MAIN_ICON"

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='dosbox'

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
tolower "$PLAYIT_WORKDIR/gamedata/$ARCHIVE_DOC_MAIN_PATH"
prepare_package_layout

# Get game icon

icons_get_from_workdir 'APP_MAIN' 'APP_HELP' 'APP_SETUP'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

launchers_write 'APP_MAIN' 'APP_HELP' 'APP_SETUP'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
