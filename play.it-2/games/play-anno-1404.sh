#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2019, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2017-2019, Phil Morrell
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
# Anno 1404: Gold Edition
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190623.6

# Set game-specific variables

GAME_ID='anno-1404'
GAME_NAME='Anno 1404'

ARCHIVE_GOG='setup_anno_1404_gold_edition_2.01.5010_(13111).exe'
ARCHIVE_GOG_URL='https://www.gog.com/game/anno_1404_gold_edition'
ARCHIVE_GOG_MD5='b19333f57c1c15b788e29ff6751dac20'
ARCHIVE_GOG_VERSION='2.01.5010-gog13111'
ARCHIVE_GOG_SIZE='6200000'
ARCHIVE_GOG_PART1='setup_anno_1404_gold_edition_2.01.5010_(13111)-1.bin'
ARCHIVE_GOG_PART1_MD5='17933b44bdb2a26d8d82ffbfdc494210'
ARCHIVE_GOG_PART1_TYPE='innosetup'
ARCHIVE_GOG_PART2='setup_anno_1404_gold_edition_2.01.5010_(13111)-2.bin'
ARCHIVE_GOG_PART2_MD5='2f71f5378b5f27a84a41cc481a482bd6'
ARCHIVE_GOG_PART2_TYPE='innosetup'

ARCHIVE_GOG_OLD0='setup_anno_1404_2.0.0.2.exe'
ARCHIVE_GOG_OLD0_MD5='9c48c8159edaee14aaa6c7e7add60623'
ARCHIVE_GOG_OLD0_VERSION='2.01.5010-gog2.0.0.2'
ARCHIVE_GOG_OLD0_SIZE='6200000'
ARCHIVE_GOG_OLD0_TYPE='rar'
ARCHIVE_GOG_OLD0_GOGID='1440426004'
ARCHIVE_GOG_OLD0_PART1='setup_anno_1404_2.0.0.2-1.bin'
ARCHIVE_GOG_OLD0_PART1_MD5='b9ee29615dfcab8178608fecaa5d2e2b'
ARCHIVE_GOG_OLD0_PART1_TYPE='rar'
ARCHIVE_GOG_OLD0_PART2='setup_anno_1404_2.0.0.2-2.bin'
ARCHIVE_GOG_OLD0_PART2_MD5='eb49c917d6218b58e738dd781e9c6751'
ARCHIVE_GOG_OLD0_PART2_TYPE='rar'

ARCHIVE_DOC_DATA_PATH='app'
ARCHIVE_DOC_DATA_FILES='*.pdf'
# Keep compatibility with old archives
ARCHIVE_DOC_DATA_PATH_GOG_OLD0='game'

ARCHIVE_GAME_BIN_PATH='app'
ARCHIVE_GAME_BIN_FILES='*.exe *.dll bin tools'
# Keep compatibility with old archives
ARCHIVE_GAME_BIN_PATH_GOG_OLD0='game'

ARCHIVE_GAME0_DATA_PATH='app'
ARCHIVE_GAME0_DATA_FILES='addon data maindata resources'
# Keep compatibility with old archives
ARCHIVE_GAME0_DATA_PATH_GOG_OLD0='game'

ARCHIVE_GAME1_DATA_PATH='app/__support/add'
ARCHIVE_GAME1_DATA_FILES='engine.ini'
# Keep compatibility with old archives
ARCHIVE_GAME1_DATA_PATH_GOG_OLD0='game'

DATA_DIRS='./userdata'

APP_WINETRICKS='d3dx9'

APP_MAIN_TYPE='wine'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='user_data_path="$WINEPREFIX/drive_c/users/$(whoami)/Application Data/Ubisoft/Anno1404"
if [ ! -e "$user_data_path" ]; then
	mkdir --parents "${user_data_path%/*}"
	mkdir --parents "$PATH_DATA/userdata"
	ln --symbolic "$PATH_DATA/userdata" "$user_data_path"
	init_prefix_dirs "$PATH_DATA" "$DATA_DIRS"
fi'
APP_MAIN_EXE='anno4.exe'
APP_MAIN_ICON='anno4.exe'

APP_VENICE_ID="${GAME_ID}_venice"
APP_VENICE_TYPE='wine'
APP_VENICE_PRERUN="$APP_MAIN_PRERUN"
APP_VENICE_EXE='addon.exe'
APP_VENICE_ICON='addon.exe'
APP_VENICE_NAME="$GAME_NAME - Venice"

APP_L10N_ID="${GAME_ID}_l10n"
APP_L10N_TYPE='wine'
APP_L10N_EXE='language_selector.exe'
APP_L10N_ICON='language_selector.exe'
APP_L10N_NAME="$GAME_NAME - language selector"
APP_L10N_CAT='Settings'

PACKAGES_LIST='PKG_DATA PKG_BIN'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID winetricks wine glx xcursor"

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

case "$ARCHIVE" in
	('ARCHIVE_GOG_OLD0')
		if [ $DRY_RUN -eq 0 ]; then
			ln --symbolic "$(readlink --canonicalize "$ARCHIVE_PART1")" "$PLAYIT_WORKDIR/$GAME_ID.r00"
			ln --symbolic "$(readlink --canonicalize "$ARCHIVE_PART2")" "$PLAYIT_WORKDIR/$GAME_ID.r01"
		fi
		extract_data_from "$PLAYIT_WORKDIR/$GAME_ID.r00"
		tolower "$PLAYIT_WORKDIR/gamedata"
	;;
	(*)
		extract_data_from "$SOURCE_ARCHIVE"
	;;
esac
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Extract icons

PKG='PKG_BIN'
icons_get_from_package 'APP_MAIN' 'APP_VENICE' 'APP_L10N'
icons_move_to 'PKG_DATA'

# Fix immediate crash

file="${PKG_DATA_PATH}${PATH_GAME}/engine.ini"
if [ -e "$file" ]; then
	pattern='2i<DirectXVersion>9</DirectXVersion>'
	if [ $DRY_RUN -eq 0 ]; then
		sed --in-place "$pattern" "$file"
	fi
else
	if [ $DRY_RUN -eq 0 ]; then
		cat > "$file" <<- 'EOF'
		<InitFile>
		<DirectXVersion>9</DirectXVersion>
		</InitFile>
		EOF
	fi
fi

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN' 'APP_VENICE' 'APP_L10N'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
