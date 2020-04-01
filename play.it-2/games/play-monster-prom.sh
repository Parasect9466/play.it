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
# Monster Prom
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200401.2

# Set game-specific variables

GAME_ID='monster-prom'
GAME_NAME='Monster Prom'

ARCHIVE_GOG='monster_prom_4_80_36450.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/monster_prom'
ARCHIVE_GOG_MD5='5847214b0bcf816d03e165a16d0c19c4'
ARCHIVE_GOG_SIZE='2400000'
ARCHIVE_GOG_VERSION='4.80-gog36450'
ARCHIVE_GOG_TYPE='mojosetup'

ARCHIVE_GOG_OLD7='monster_prom_4_79_36279.sh'
ARCHIVE_GOG_OLD7_MD5='c1d893075a21af380031c953e856bd7c'
ARCHIVE_GOG_OLD7_SIZE='2400000'
ARCHIVE_GOG_OLD7_VERSION='4.79-gog36279'
ARCHIVE_GOG_OLD7_TYPE='mojosetup'

ARCHIVE_GOG_OLD6='monster_prom_4_77_36137.sh'
ARCHIVE_GOG_OLD6_MD5='87a05cfec3a314c4a6ea1047154958cf'
ARCHIVE_GOG_OLD6_SIZE='2400000'
ARCHIVE_GOG_OLD6_VERSION='4.77-gog36137'
ARCHIVE_GOG_OLD6_TYPE='mojosetup'

ARCHIVE_GOG_OLD5='monster_prom_4_68_35225.sh'
ARCHIVE_GOG_OLD5_MD5='c48257dadd81ac089b10567733beea48'
ARCHIVE_GOG_OLD5_SIZE='2200000'
ARCHIVE_GOG_OLD5_VERSION='4.68-gog35225'
ARCHIVE_GOG_OLD5_TYPE='mojosetup'

ARCHIVE_GOG_OLD4='monster_prom_4_61_33782.sh'
ARCHIVE_GOG_OLD4_MD5='0ed680d8cf93810c80f2c2f02ce16ae6'
ARCHIVE_GOG_OLD4_SIZE='2200000'
ARCHIVE_GOG_OLD4_VERSION='4.61-gog33782'
ARCHIVE_GOG_OLD4_TYPE='mojosetup'

ARCHIVE_GOG_OLD3='monster_prom_4_57_33526.sh'
ARCHIVE_GOG_OLD3_MD5='62a6e7d2bf6dc9ede39ec014cd73aaf4'
ARCHIVE_GOG_OLD3_SIZE='2200000'
ARCHIVE_GOG_OLD3_VERSION='4.57-gog33526'
ARCHIVE_GOG_OLD3_TYPE='mojosetup'

ARCHIVE_GOG_OLD2='monster_prom_4_44_30880.sh'
ARCHIVE_GOG_OLD2_MD5='feea2789e951c992e714a0d01afb7348'
ARCHIVE_GOG_OLD2_SIZE='2000000'
ARCHIVE_GOG_OLD2_VERSION='4.44-gog30880'
ARCHIVE_GOG_OLD2_TYPE='mojosetup'

ARCHIVE_GOG_OLD1='monster_prom_4_38b_30736.sh'
ARCHIVE_GOG_OLD1_MD5='4dc9b48a90220ecc0fcd91e44f640320'
ARCHIVE_GOG_OLD1_SIZE='2000000'
ARCHIVE_GOG_OLD1_VERSION='4.38b-gog30736'
ARCHIVE_GOG_OLD1_TYPE='mojosetup'

ARCHIVE_GOG_OLD0='monster_prom_2_44_26055.sh'
ARCHIVE_GOG_OLD0_MD5='c558e2ba0540ba6651a35a3a5e2a146b'
ARCHIVE_GOG_OLD0_SIZE='1400000'
ARCHIVE_GOG_OLD0_VERSION='2.44-gog26055'
ARCHIVE_GOG_OLD0_TYPE='mojosetup'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='MonsterProm.x86 MonsterProm_Data/*/x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='MonsterProm.x86_64 MonsterProm_Data/*/x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='MonsterProm_Data UserData'

DATA_DIRS='./logs ./UserData'

APP_MAIN_TYPE='unity3d'
APP_MAIN_EXE_BIN32='MonsterProm.x86'
APP_MAIN_EXE_BIN64='MonsterProm.x86_64'
APP_MAIN_ICON='MonsterProm_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ glx libxrandr alsa"
PKG_BIN32_DEPS_ARCH='lib32-libx11 lib32-libxext'
PKG_BIN32_DEPS_DEB='libx11-6, libxext6'
PKG_BIN32_DEPS_GENTOO='x11-libs/libX11[abi_x86_32] x11-libs/libXext[abi_x86_32]'

PKG_BIN64_ARCH='64'
PKG_BIN64_DEPS="$PKG_BIN32_DEPS"
PKG_BIN64_DEPS_ARCH='libx11 libxext'
PKG_BIN64_DEPS_DEB="$PKG_BIN32_DEPS_DEB"
PKG_BIN64_DEPS_GENTOO='x11-libs/libX11 x11-libs/libXext'

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

# Get icon

PKG='PKG_DATA'
icons_get_from_package 'APP_MAIN'

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
