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
# Terra Feminarum: Aurora Edition
# build native packages from the original installers
# send your bug reports to vv221@dotslashplay.it
###

script_version=20200502.3

# Set game-specific variables

GAME_ID='terra-feminarum-aurora-edition'
GAME_NAME='Terra Feminarum: Aurora Edition'

ARCHIVES_LIST='ARCHIVE_ITCH_0'

ARCHIVE_ITCH_0='terra_feminarum_aurora_edition_2.0.zip'
ARCHIVE_ITCH_0_URL='https://png.itch.io/terra-feminarum-aurora-edition'
ARCHIVE_ITCH_0_MD5='e3584397bcef085ec1b638221fd8ca87'
ARCHIVE_ITCH_0_VERSION='2.0-itch'
ARCHIVE_ITCH_0_SIZE='560000' # Would be 350000 without the inner jar extraction
ARCHIVE_ITCH_0_TYPE='zip'

ARCHIVE_REQUIRED_GDX='libgdx-1.6.1.zip'
ARCHIVE_REQUIRED_GDX_URL='https://libgdx.badlogicgames.com/old-site/releases/'
ARCHIVE_REQUIRED_GDX_MD5='ec10c2b06ed1494da1a9f4f2a3c49101'
ARCHIVE_REQUIRED_GDX_SIZE='130000'
ARCHIVE_REQUIRED_GDX_TYPE='zip'

ARCHIVE_REQUIRED_LWJGL='lwjgl.jar'
ARCHIVE_REQUIRED_LWJGL_URL='https://www.lwjgl.org/browse/release/3.2.3/bin/lwjgl'
ARCHIVE_REQUIRED_LWJGL_MD5='2ecc76e5c61dccd1e82f86748006473b'
ARCHIVE_REQUIRED_LWJGL_SIZE='1892'
ARCHIVE_REQUIRED_LWJGL_TYPE='zip'

ARCHIVE_REQUIRED_LWJGL_NATIVES='lwjgl-natives-linux.jar'
ARCHIVE_REQUIRED_LWJGL_NATIVES_URL='https://www.lwjgl.org/browse/release/3.2.3/bin/lwjgl'
ARCHIVE_REQUIRED_LWJGL_NATIVES_MD5='c0d0cb6af2b93f987dbf5a661d076b7e'
ARCHIVE_REQUIRED_LWJGL_NATIVES_SIZE='348'
ARCHIVE_REQUIRED_LWJGL_NATIVES_TYPE='zip'

ARCHIVE_REQUIRED_LWJGL_GLFW='lwjgl-glfw.jar'
ARCHIVE_REQUIRED_LWJGL_GLFW_URL='https://www.lwjgl.org/browse/release/3.2.3/bin/lwjgl-glfw'
ARCHIVE_REQUIRED_LWJGL_GLFW_MD5='8e466fd7a961b6a00252b9f162d3ff63'
ARCHIVE_REQUIRED_LWJGL_GLFW_SIZE='468'
ARCHIVE_REQUIRED_LWJGL_GLFW_TYPE='zip'

ARCHIVE_REQUIRED_LWJGL_OPENAL='lwjgl-openal.jar'
ARCHIVE_REQUIRED_LWJGL_OPENAL_URL='https://www.lwjgl.org/browse/release/3.2.3/bin/lwjgl-openal'
ARCHIVE_REQUIRED_LWJGL_OPENAL_MD5='73cdf3c8861a815d9f979fab6a14b8fd'
ARCHIVE_REQUIRED_LWJGL_OPENAL_SIZE='364'
ARCHIVE_REQUIRED_LWJGL_OPENAL_TYPE='zip'

ARCHIVE_REQUIRED_LWJGL_OPENGL='lwjgl-opengl.jar'
ARCHIVE_REQUIRED_LWJGL_OPENGL_URL='https://www.lwjgl.org/browse/release/3.2.3/bin/lwjgl-opengl'
ARCHIVE_REQUIRED_LWJGL_OPENGL_MD5='a774338dc1fff3af3ea56a9dde6a71cf'
ARCHIVE_REQUIRED_LWJGL_OPENGL_SIZE='3716'
ARCHIVE_REQUIRED_LWJGL_OPENGL_TYPE='zip'

ARCHIVE_REQUIRED_LWJGL_OPENGL_NATIVES='lwjgl-opengl-natives-linux.jar'
ARCHIVE_REQUIRED_LWJGL_OPENGL_NATIVES_URL='https://www.lwjgl.org/browse/release/3.2.3/bin/lwjgl-opengl'
ARCHIVE_REQUIRED_LWJGL_OPENGL_NATIVES_MD5='3df5002e8a108662723a53c52f237aba'
ARCHIVE_REQUIRED_LWJGL_OPENGL_NATIVES_SIZE='372'
ARCHIVE_REQUIRED_LWJGL_OPENGL_NATIVES_TYPE='zip'

ARCHIVE_OPTIONAL_LWJGL_GLFW_NATIVES='lwjgl-glfw-natives-linux.jar'
ARCHIVE_OPTIONAL_LWJGL_GLFW_NATIVES_URL='https://www.lwjgl.org/browse/release/3.2.3/bin/lwjgl-glfw'
ARCHIVE_OPTIONAL_LWJGL_GLFW_NATIVES_MD5='1c9354d479064c4710f34d277548a21b'
ARCHIVE_OPTIONAL_LWJGL_GLFW_NATIVES_SIZE='560'
ARCHIVE_OPTIONAL_LWJGL_GLFW_NATIVES_TYPE='zip'

ARCHIVE_GAME_DATA_PATH='.'
ARCHIVE_GAME_DATA_FILES='data'

ARCHIVE_GAME0_BIN_PATH='.'
ARCHIVE_GAME0_BIN_FILES='tf com org libsteamworks4j.so libsteam_api.so libgdx64.so libgdx-freetype64.so linux/x64/org/lwjgl/glfw/libglfw.so linux/x64/org/lwjgl/glfw/libglfw_wayland.so linux/x64/org/lwjgl/opengl/liblwjgl_opengl.so'

ARCHIVE_GAME1_BIN_PATH='linux/x64/org/lwjgl'
ARCHIVE_GAME1_BIN_FILES='liblwjgl.so'

APP_MAIN_TYPE='java'
APP_MAIN_EXE='tf/launcher/Launcher.class'

PACKAGES_LIST='PKG_BIN PKG_DATA'

PKG_DATA_ID="${GAME_ID}-data"
PKG_DATA_DESCRIPTION='data'

PKG_BIN_ARCH='64'
PKG_BIN_DEPS="$PKG_DATA_ID java glx openal"

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

# Check for extra archives

ARCHIVE_MAIN="$ARCHIVE"
for archive in GDX LWJGL LWJGL_NATIVES LWJGL_GLFW LWJGL_OPENAL LWJGL_OPENGL LWJGL_OPENGL_NATIVES; do
	archive_set "ARCHIVE_$archive" "ARCHIVE_REQUIRED_$archive"
	[ "$(get_value ARCHIVE_$archive)" ] || archive_set_error_not_found "ARCHIVE_REQUIRED_$archive"
done
archive_set 'ARCHIVE_LWJGL_GLFW_NATIVES' 'ARCHIVE_OPTIONAL_LWJGL_GLFW_NATIVES'
if [ -z "$ARCHIVE_LWJGL_GLFW_NATIVES" ]; then
	PKG_BIN_DEPS_DEB="$PKG_BIN_DEPS_DEB libglfw3 (>= 3.3)"
	PKG_BIN_DEPS_ARCH="$PKG_BIN_DEPS_ARCH glfw>=3.3"
	PKG_BIN_DEPS_GENTOO="$PKG_BIN_DEPS_GENTOO >=media-libs/glfw-3.3"
fi
ARCHIVE="$ARCHIVE_MAIN"

# Extract game data

extract_data_from "$SOURCE_ARCHIVE"
(
        ARCHIVE='INNER_ARCHIVE'
        INNER_ARCHIVE="$PLAYIT_WORKDIR/gamedata/TerraFeminarum/terra_feminarum.jar"
        INNER_ARCHIVE_TYPE='zip'
        extract_data_from "$INNER_ARCHIVE"
        rm "$INNER_ARCHIVE"
)
rm "$PLAYIT_WORKDIR/gamedata/"*.dll
rm --recursive "$PLAYIT_WORKDIR/gamedata/org/lwjgl"
for archive in GDX LWJGL LWJGL_NATIVES LWJGL_GLFW LWJGL_OPENAL LWJGL_OPENGL LWJGL_OPENGL_NATIVES LWJGL_GLFW_NATIVES; do
	[ "$(get_value ARCHIVE_$archive)" ] || continue
	(
		ARCHIVE="ARCHIVE_$archive"
		extract_data_from "$(get_value ARCHIVE_$archive)"
		[ -d "$PLAYIT_WORKDIR/gamedata/META-INF" ] && rm --recursive "$PLAYIT_WORKDIR/gamedata/META-INF"
	)
done
(
	ARCHIVE='INNER_ARCHIVE'
	INNER_ARCHIVE_TYPE='zip'
	for INNER_ARCHIVE in "$PLAYIT_WORKDIR/gamedata/gdx-natives.jar" "$PLAYIT_WORKDIR/gamedata/extensions/gdx-freetype/gdx-freetype-natives.jar"; do
		extract_data_from "$INNER_ARCHIVE"
		rm "$INNER_ARCHIVE"
		[ -d "$PLAYIT_WORKDIR/gamedata/META-INF" ] && rm --recursive "$PLAYIT_WORKDIR/gamedata/META-INF"
	done
)
prepare_package_layout
rm --recursive "$PLAYIT_WORKDIR/gamedata"

# Write launchers

PKG='PKG_BIN'
launchers_write 'APP_MAIN'
if [ $DRY_RUN -eq 0 ]; then
	sed --in-place --regexp-extended "s/^(APP_EXE='.*)\.class'$/\1'/;s/^(java .*)-jar(.*)/\1\2/" "${PKG_BIN_PATH}${PATH_BIN}/$GAME_ID"
fi

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
