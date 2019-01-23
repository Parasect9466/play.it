#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
# Copyright (c) 2018, Solène Huault
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
# Lyne
# build native Linux packages from the original installers
# send your bug reports to mopi@dotslashplay.it
###

script_version=20180912.1

# Set game-specific variables

GAME_ID='lyne'
GAME_NAME='Lyne'

ARCHIVE_HUMBLE='LYNE_120_lin.zip'
ARCHIVE_HUMBLE_URL='https://www.humblebundle.com/store/lyne'
ARCHIVE_HUMBLE_MD5='f05951586a5b8cf42e20e0e6f04e65da'
ARCHIVE_HUMBLE_SIZE='110000'
ARCHIVE_HUMBLE_VERSION='1.2.0.30-humble171211'
ARCHIVE_HUMBLE_TYPE='zip'

ARCHIVE_DOC_PATH='LYNE_120_lin'
ARCHIVE_DOC_FILES='readme.txt'

ARCHIVE_GAME_BIN32_PATH='LYNE_120_lin'
ARCHIVE_GAME_BIN32_FILES='LYNE.x86 LYNE_Data/*/x86'

ARCHIVE_GAME_BIN64_PATH='LYNE_120_lin'
ARCHIVE_GAME_BIN64_FILES='LYNE.x86_64 LYNE_Data/*/x86_64'

ARCHIVE_GAME_DATA_PATH='LYNE_120_lin'
ARCHIVE_GAME_DATA_FILES='LYNE_Data'

DATA_DIRS='./logs'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='file="$HOME/.config/unity3d/Thomas Bowker/LYNE/prefs"
if [ ! -e "$file" ]; then
	mkdir --parents "${file%/*}"
	cat > "$file" <<- EOF
		<unity_prefs version_major="1" version_minor="1">
		<pref name="Screenmanager Is Fullscreen mode" type="int">0</pref>
		</unity_prefs>
	EOF
fi
export LANG=C'
APP_MAIN_EXE_BIN32='LYNE.x86'
APP_MAIN_EXE_BIN64='LYNE.x86_64'
APP_MAIN_OPTIONS='-logFile ./logs/$(date +%F-%R).log'
APP_MAIN_ICON='LYNE_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ gtk2"

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Load common functions

target_version='2.10'

if [ -z "$PLAYIT_LIB2" ]; then
	: ${XDG_DATA_HOME:="$HOME/.local/share"}
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
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	write_launcher 'APP_MAIN'
done

# Build package

PKG='PKG_DATA'
icons_linking_postinst 'APP_MAIN'
write_metadata 'PKG_DATA'
write_metadata 'PKG_BIN32' 'PKG_BIN64'
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
