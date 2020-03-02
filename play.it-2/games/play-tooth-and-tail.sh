#!/bin/sh
set -o errexit

###
# Copyright (c) 2015-2020, Antoine "vv221/vv222" Le Gonidec
# Copyright (c) 2018-2020, BetaRays
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
# Tooth and Tail
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200302.4

# Set game-specific variables

GAME_ID='tooth-and-tail'
GAME_NAME='Tooth and Tail'

ARCHIVE_HUMBLE='toothandtail_linux.zip'
ARCHIVE_HUMBLE_MD5='a05d5b59d18c52c56e5ca52515002ed5'
ARCHIVE_HUMBLE_VERSION='1.4.0.1-humble1'
ARCHIVE_HUMBLE_SIZE='600000'

ARCHIVE_GAME_LIBS32_PATH='.'
ARCHIVE_GAME_LIBS32_FILES='lib/libfmod.so.10 lib/libfmodstudio.so.10 lib/libmojoshader.so lib/libtheorafile.so'

ARCHIVE_GAME_LIBS64_PATH='.'
ARCHIVE_GAME_LIBS64_FILES='lib64/libfmod.so.10 lib64/libfmodstudio.so.10 lib64/libmojoshader.so lib64/libtheorafile.so'

ARCHIVE_GAME_MAIN_PATH='.'
ARCHIVE_GAME_MAIN_FILES='
*.dll *.exe *config fr/*.dll
content'

DATA_DIRS='logs'

APP_MAIN_TYPE='mono'
APP_MAIN_LIBS='lib'
# shellcheck disable=SC2016
APP_MAIN_PRERUN='# Work around terminfo Mono bug, cf. https://github.com/mono/mono/issues/6752
export TERM="${TERM%-256color}"'
APP_MAIN_EXE='ToothAndTail.exe'
APP_MAIN_ICON='ToothAndTail.exe'

PACKAGES_LIST='PKG_MAIN PKG_LIBS32 PKG_LIBS64'

PKG_LIBS_ID="${GAME_ID}-libs"

PKG_LIBS32_ARCH='32'
PKG_LIBS32_ID="$PKG_LIBS_ID"
PKG_LIBS32_DEPS='openal sdl2 sdl2_image theora vorbis'
PKG_LIBS32_DEPS_ARCH='lib32-libjpeg6 lib32-libogg lib32-libpng15'
PKG_LIBS32_DEPS_GENTOO='virtual/jpeg:62[abi_x86_32] media-libs/libogg[abi_x86_32] media-libs/libpng:1.5[abi_x86_32]'

PKG_LIBS64_ARCH='64'
PKG_LIBS64_ID="$PKG_LIBS_ID"
PKG_LIBS64_DEPS="$PKG_LIBS32_DEPS"
PKG_LIBS64_DEPS_ARCH='libjpeg6 libogg libpng15'
PKG_LIBS64_DEPS_GENTOO="virtual/jpeg:62 media-libs/libogg media-libs/libpng:1.5"

PKG_MAIN_DEPS="$GAME_ID-libs mono"

# Load common functions

target_version='2.12'

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

# Make multiple architectures easier to handle

mv "${PKG_LIBS64_PATH}${PATH_GAME}/lib64" "${PKG_LIBS64_PATH}${PATH_GAME}/lib"

# Get game icon

PKG='PKG_MAIN'
icons_get_from_package 'APP_MAIN'

# Write launchers

PKG='PKG_MAIN'
launchers_write 'APP_MAIN'

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
