#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2020, Dominique Derrier
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
# Dune Ⅱ: Battle for Arrakis
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200303.5

# Set game-specific variables

GAME_ID='dune-2'
GAME_NAME='Dune Ⅱ: Battle for Arrakis'

ARCHIVE_LTF='setup-00022-DuneII-PCDOS.exe'
ARCHIVE_LTF_URL='https://www.abandonware-france.org/ltf_abandon/ltf_jeu.php?id=22'
ARCHIVE_LTF_MD5='b2e6aa471d07d846cd6df3ed1d8ecb0c'
ARCHIVE_LTF_VERSION='1.07-ltf00022'
ARCHIVE_LTF_TYPE='innosetup'
ARCHIVE_LTF_SIZE='340000'

ARCHIVE_GAME_MAIN_PATH='app/c/dune2'
ARCHIVE_GAME_MAIN_FILES='dune2.exe setup.exe setup*.dip *.pak *.dat *.cfg'

APP_MAIN_TYPE='dosbox'
APP_MAIN_EXE='dune2.exe'
APP_MAIN_ICON='app/dune2.ico'

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
prepare_package_layout

# Get game icon
# As it is not using a standard size (99x99 pixels), it needs resizing

PATH_ICON="${PATH_ICON_BASE}/72x72/apps"
source="$PLAYIT_WORKDIR/gamedata/$APP_MAIN_ICON"
destination="${PKG_MAIN_PATH}${PATH_ICON}/${GAME_ID}.png"
mkdir --parents "$(dirname "$destination")"
convert "$source" -resize 72 "$destination"
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
