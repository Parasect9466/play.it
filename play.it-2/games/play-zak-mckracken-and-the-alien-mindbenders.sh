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
# Zak McKracken and the Alien Mindbenders
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20200209.1

# Set game-specific variables

GAME_ID='zak-mckracken-and-the-alien-mindbenders'
GAME_NAME='Zak McKracken and the Alien Mindbenders'

ARCHIVE_GOG='zak_mckracken_and_the_alien_mindbenders_en_gog_2_20099.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/zak_mckracken_and_the_alien_mindbenders'
ARCHIVE_GOG_MD5='eb144295c6387b71ac2e78986067ba30'
ARCHIVE_GOG_SIZE='190000'
ARCHIVE_GOG_VERSION='1.0-gog20099'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_DOC_MAIN_PATH='data/noarch/docs'
ARCHIVE_DOC_MAIN_FILES='*.pdf *.txt'

ARCHIVE_GAME_MAIN_PATH='data/noarch/data'
ARCHIVE_GAME_MAIN_FILES='*.lfl *.mp3'

APP_MAIN_TYPE='scummvm'
APP_MAIN_SCUMMID='zak'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_DEPS='scummvm'

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
tolower "$PLAYIT_WORKDIR/gamedata"
prepare_package_layout

# Get icon

icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
