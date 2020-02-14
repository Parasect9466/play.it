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
# Lords of Xulima
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200214.6

# Set game-specific variables

GAME_ID='lords-of-xulima'
GAME_NAME='Lords of Xulima'

ARCHIVE_GOG='gog_lords_of_xulima_2.3.0.9.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/lords_of_xulima'
ARCHIVE_GOG_MD5='480abf8d929da622eacd69595a4ebc80'
ARCHIVE_GOG_SIZE='1700000'
ARCHIVE_GOG_VERSION='2.1.1-gog2.3.0.9'

ARCHIVE_GAME_BIN_PATH='data/noarch/game'
ARCHIVE_GAME_BIN_FILES='etc Linux *.conf *.config *.cpp *.dll *.exe *.hqx *.manifest *.so LOXLinux MusicPlayer'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='DXApp_* SOL_* Cinematic CSteamworks.bundle Manual Resources *.dx* *.fx *.glsl *.icns *.jx* *.sqlite *.suo *.ttf *.txt SOL'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS='Linux/lib'
APP_MAIN_PRERUN='# Work around terminfo Mono bug
# cf. https://github.com/mono/mono/issues/6752
export TERM="${TERM%-256color}"'
APP_MAIN_EXE='LOXLinux'
APP_MAIN_OPTIONS='--gc=sgen'
APP_MAIN_ICON='LoX.exe'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='32'
PKG_BIN_DEPS="$PKG_DATA_ID glibc libstdc++ glx gtk2"
PKG_BIN_DEPS_ARCH='lib32-libxext'
PKG_BIN_DEPS_DEB='libxext6'
PKG_BIN_DEPS_GENTOO='x11-libs/libXext[abi_x86_32]'

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
