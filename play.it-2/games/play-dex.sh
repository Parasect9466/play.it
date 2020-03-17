#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2016-2020, Mopi
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
# Dex
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200317.4

# Set game-specific variables

GAME_ID='dex-game'
GAME_NAME='Dex'

ARCHIVE_GOG='dex_en_6_0_0_0_build_5553_17130.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/dex'
ARCHIVE_GOG_MD5='3d6f8797fab72dcb867c92bf5a84b4dd'
ARCHIVE_GOG_SIZE='6300000'
ARCHIVE_GOG_VERSION='6.0.0.0.5553-gog17130'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='gog_dex_2.3.0.4.sh'
ARCHIVE_GOG_OLD0_MD5='199a1acc59879124e8e1c532909fd879'
ARCHIVE_GOG_OLD0_SIZE='6200000'
ARCHIVE_GOG_OLD0_VERSION='5.4.0.0-gog2.3.0.4'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='Dex.x86 Dex_Data/Mono Dex_Data/Plugins'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='Dex_Data'

APP_MAIN_TYPE='unity3d'
APP_MAIN_EXE='Dex.x86'
APP_MAIN_ICON='Dex_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx xcursor libxrandr alsa libudev1"
PKG_BIN_DEPS_ARCH='lib32-libx11 lib32-gdk-pixbuf2 lib32-glib2'
PKG_BIN_DEPS_DEB='libx11-6, libgdk-pixbuf2.0-0, libglib2.0-0'
PKG_BIN_DEPS_GENTOO='x11-libs/libX11[abi_x86_32] x11-libs/gdk-pixbuf[abi_x86_32] dev-libs/glib[abi_x86_32]'

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
