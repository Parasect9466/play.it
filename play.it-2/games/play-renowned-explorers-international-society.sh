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
# Renowned Explorers: International Society
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20190619.2

# Set game-specific variables

GAME_ID='renowned-explorers-international-society'
GAME_NAME='Renowned Explorers: International Society'

ARCHIVE_GOG='renowned_explorers_international_society_522_26056.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/renowned_explorers'
ARCHIVE_GOG_MD5='fe38ae1c4dc2607923cc2a60019bff38'
ARCHIVE_GOG_SIZE='1200000'
ARCHIVE_GOG_VERSION='522-gog26056'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD8='renowned_explorers_international_society_520_25983.sh'
ARCHIVE_GOG_OLD8_MD5='2af1dedb29ac1b929971cc0912722760'
ARCHIVE_GOG_OLD8_SIZE='1200000'
ARCHIVE_GOG_OLD8_VERSION='520-gog25983'
ARCHIVE_GOG_OLD8_TYPE='mojosetup'

ARCHIVE_GOG_OLD7='renowned_explorers_international_society_516_25864.sh'
ARCHIVE_GOG_OLD7_MD5='d868d4b76613b93a94650b750a52752f'
ARCHIVE_GOG_OLD7_SIZE='1200000'
ARCHIVE_GOG_OLD7_VERSION='516-gog25864'
ARCHIVE_GOG_OLD7_TYPE='mojosetup'

ARCHIVE_GOG_OLD6='renowned_explorers_international_society_512_25169.sh'
ARCHIVE_GOG_OLD6_MD5='3f2eb242da5200a78c53162d152a3cac'
ARCHIVE_GOG_OLD6_SIZE='1100000'
ARCHIVE_GOG_OLD6_VERSION='512-gog25169'
ARCHIVE_GOG_OLD6_TYPE='mojosetup'

ARCHIVE_GOG_OLD5='renowned_explorers_international_society_508_23701.sh'
ARCHIVE_GOG_OLD5_MD5='247551613c7aba4b4b31f7a98fa31949'
ARCHIVE_GOG_OLD5_SIZE='1100000'
ARCHIVE_GOG_OLD5_VERSION='508-gog23701'
ARCHIVE_GOG_OLD5_TYPE='mojosetup'

ARCHIVE_GOG_OLD4='renowned_explorers_international_society_503_23529.sh'
ARCHIVE_GOG_OLD4_MD5='6b7555749bc89cc3dda223e2d43bd838'
ARCHIVE_GOG_OLD4_SIZE='1100000'
ARCHIVE_GOG_OLD4_VERSION='503-gog23529'
ARCHIVE_GOG_OLD4_TYPE='mojosetup'

ARCHIVE_GOG_OLD3='renowned_explorers_international_society_en_489_21590.sh'
ARCHIVE_GOG_OLD3_MD5='9fb2cbe095d437d788eb8ec6402db20b'
ARCHIVE_GOG_OLD3_SIZE='1100000'
ARCHIVE_GOG_OLD3_VERSION='489-gog21590'
ARCHIVE_GOG_OLD3_TYPE='mojosetup'

ARCHIVE_GOG_OLD2='renowned_explorers_international_society_en_489_20916.sh'
ARCHIVE_GOG_OLD2_MD5='42d0ecb54d8302545e78f41ed43acef6'
ARCHIVE_GOG_OLD2_SIZE='1100000'
ARCHIVE_GOG_OLD2_VERSION='489-gog20916'
ARCHIVE_GOG_OLD2_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='renowned_explorers_international_society_en_466_15616.sh'
ARCHIVE_GOG_OLD1_MD5='fbad4b4d361a0e7d29b9781e3c5a5e85'
ARCHIVE_GOG_OLD1_SIZE='1100000'
ARCHIVE_GOG_OLD1_VERSION='466-gog15616'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='renowned_explorers_international_society_en_459_14894.sh'
ARCHIVE_GOG_OLD0_MD5='ff6b368b3919002d2db750213d33fcef'
ARCHIVE_GOG_OLD0_SIZE='1100000'
ARCHIVE_GOG_OLD0_VERSION='459-gog14894'
ARCHIVE_GOG_OLD0_TYPE='mojosetup'

ARCHIVE_DOC_DATA_PATH='data/noarch/docs'
ARCHIVE_DOC_DATA_FILES='*'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='x86/abbeycore x86/libc++.so.1 x86/libc++abi.so.1'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='x86_64/abbeycore x86_64/libc++.so.1 x86_64/libc++abi.so.1'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='build.bni data project.bni settings.ini soundbanks'

CONFIG_FILES='./*.ini'
DATA_DIRS='./savedata ./userdata'
DATA_FILES='./*.txt'

APP_MAIN_TYPE='native'
APP_MAIN_PRERUN='export LANG=C'
APP_MAIN_EXE_BIN32='x86/abbeycore'
APP_MAIN_EXE_BIN64='x86_64/abbeycore'
APP_MAIN_ICON='data/noarch/support/icon.png'

PACKAGES_LIST='PKG_DATA PKG_BIN32 PKG_BIN64'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ glx glu xcursor sdl2 libxrandr"
PKG_BIN32_DEPS_ARCH='lib32-libx11'
PKG_BIN32_DEPS_DEB='libx11-6'
PKG_BIN32_DEPS_GENTOO='x11-libs/libX11[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='libx11'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_GENTOO='x11-libs/libX11'

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

# Get icon

PKG='PKG_DATA'
icons_get_from_workdir 'APP_MAIN'
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

for PKG in 'PKG_BIN32' 'PKG_BIN64'; do
	launchers_write 'APP_MAIN'
done

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
