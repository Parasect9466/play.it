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
# Satellite Reign
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200422.2

# Set game-specific variables

GAME_ID='satellite-reign'
GAME_NAME='Satellite Reign'

ARCHIVES_LIST='
ARCHIVE_GOG_1
ARCHIVE_GOG_0
'

ARCHIVE_GOG_1='gog_satellite_reign_2.8.0.10.sh'
ARCHIVE_GOG_1_MD5='5a22cdb3e721bbed7bc5836e769caa0a'
ARCHIVE_GOG_1_TYPE='mojosetup'
ARCHIVE_GOG_1_URL='https://www.gog.com/game/satellite_reign'
ARCHIVE_GOG_1_SIZE='1400000'
ARCHIVE_GOG_1_VERSION='1.13.06-gog2.8.0.10'

ARCHIVE_GOG_0='gog_satellite_reign_2.6.0.8.sh'
ARCHIVE_GOG_0_MD5='0e050bac1c75632b094097132fa6be72'
ARCHIVE_GOG_0_TYPE='mojosetup'
ARCHIVE_GOG_0_SIZE='1400000'
ARCHIVE_GOG_0_VERSION='1.07.08-gog2.6.0.8'

ARCHIVE_DOC_DATA_PATH='data/noarch/game'
ARCHIVE_DOC_DATA_FILES='Linux_GPU_DriverInfo.txt'

ARCHIVE_GAME_BIN32_PATH='data/noarch/game'
ARCHIVE_GAME_BIN32_FILES='SatelliteReignLinux.x86 SatelliteReignLinux_Data/Mono/x86 SatelliteReignLinux_Data/Plugins/x86'

ARCHIVE_GAME_BIN64_PATH='data/noarch/game'
ARCHIVE_GAME_BIN64_FILES='SatelliteReignLinux.x86_64 SatelliteReignLinux_Data/Mono/x86_64 SatelliteReignLinux_Data/Plugins/x86_64'

ARCHIVE_GAME_DATA_PATH='data/noarch/game'
ARCHIVE_GAME_DATA_FILES='SatelliteReignLinux_Data'

APP_MAIN_TYPE='unity3d'
APP_MAIN_EXE_BIN32='SatelliteReignLinux.x86'
APP_MAIN_EXE_BIN64='SatelliteReignLinux.x86_64'
APP_MAIN_ICON='SatelliteReignLinux_Data/Resources/UnityPlayer.png'

PACKAGES_LIST='PKG_BIN32 PKG_BIN64 PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN32_ARCH='32'
PKG_BIN32_DEPS="$PKG_DATA_ID glibc libstdc++ glx xcursor libxrandr gtk2"
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

# Delete unwanted empty Mac OS directories

plugins_path="$PLAYIT_WORKDIR/gamedata/data/noarch/games/SatelliteReignLinux_Data/Plugins"
rm --force --recursive \
	"$plugins_path/CSteamworks.bundle" \
	"$plugins_path/ShroudUnityPlugin.bundle"

# Prepare package

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
