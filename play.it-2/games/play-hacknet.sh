#!/bin/sh -e
set -o errexit

###
# Copyright (c) 2018-2020, VA
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
# Hacknet
# build native packages from the original installers
# send your bug reports to dev+playit@indigo.re
###

script_version=20180918.1

# Set game-specific variables

GAME_ID='hacknet'
GAME_NAME='Hacknet'

ARCHIVE_GOG='hacknet_en_5_069_15083.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/hacknet'
ARCHIVE_GOG_MD5='305d230cad47d696e4141320189cd4bc'
ARCHIVE_GOG_SIZE='350000'
ARCHIVE_GOG_VERSION='5.069-gog15083'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='./*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='./*.bin.x86 ./lib/libcef.so ./lib/libCSteamworks.so ./lib/libjpeg.so.62 ./lib/libmojoshader.so ./lib/libmono-2.0.so.1 ./lib/libogg.so.0 ./lib/libopenal.so.1 ./lib/libpng15.so.15 ./lib/libSDL2-2.0.so.0 ./lib/libSDL2_image-2.0.so.0 ./lib/libsteam_api.so ./lib/libtheoradec.so.1 ./lib/libtheoraplay.so ./lib/libvorbisfile.so.3 ./lib/libvorbis.so.0 ./lib/libXNAWebRenderer.so'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='./*.bin.x86_64 ./lib64/libcef.so ./lib64/libCSteamworks.so ./lib64/libjpeg.so.62 ./lib64/libmojoshader.so ./lib64/libmono-2.0.so.1 ./lib64/libogg.so.0 ./lib64/libopenal.so.1 ./lib64/libpng15.so.15 ./lib64/libSDL2-2.0.so.0 ./lib64/libSDL2_image-2.0.so.0 ./lib64/libsteam_api.so ./lib64/libtheoradec.so.1 ./lib64/libtheoraplay.so ./lib64/libvorbisfile.so.3 ./lib64/libvorbis.so.0 ./lib64/libXNAWebRenderer.so'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='./Hacknet.exe ./*.dll ./Content ./*.pak ./Hacknet.bmp ./locales ./Extensions ./icudtl.dat ./natives_blob.bin ./snapshot_blob.bin ./FNA.dll.config ./mono'

DATA_DIRS='./logs ./Content/People'

APP_MAIN_TYPE='native'
APP_MAIN_LIBS_BIN32='lib'
APP_MAIN_LIBS_BIN64='lib64'
APP_MAIN_EXE_BIN32='./Hacknet.bin.x86'
APP_MAIN_EXE_BIN64='./Hacknet.bin.x86_64'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ openal sdl2 sdl2_image vorbis theora"
PKG_BIN32_DEPS_DEB='libjpeg62-turbo | libjpeg62'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"

# Load common functions

target_version='2.10'

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
#shellcheck source=play.it-2/lib/libplayit2.sh
. "$PLAYIT_LIB2"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
prepare_package_layout

# Extract icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Ensure that Chromium Embedded Framework is functional

chmod +x "${PKG_BIN32_PATH}${PATH_GAME}/cefprocess.bin.x86"
chmod +x "${PKG_BIN64_PATH}${PATH_GAME}/cefprocess.bin.x86_64"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	write_launcher 'APP_MAIN'
done

# Fix a crash when starting from some terminals

# shellcheck disable=SC2016
pattern='s#^"\./$APP_EXE" .*#& > ./logs/$(date +%F-%R).log#'
sed --in-place "$pattern" "${PKG_BIN32_PATH}${PATH_BIN}/$GAME_ID"
sed --in-place "$pattern" "${PKG_BIN64_PATH}${PATH_BIN}/$GAME_ID"

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "${PLAYIT_WORKDIR}"

# Print instructions

print_instructions

exit 0
