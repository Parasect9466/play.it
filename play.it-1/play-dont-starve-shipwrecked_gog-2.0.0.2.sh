#!/bin/sh -e

###
# Copyright (c) 2015-2018, Antoine Le Gonidec
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
# conversion script for the the Don’t Starve: Shipwrecked installer sold on GOG.com
# build a .deb package from the MojoSetup (.sh) installer
#
# send your bug reports to vv221@dotslashplay.it
###

script_version=20160530.1

# Set game-specific variables

SCRIPT_DEPS_HARD='fakeroot unzip'

GAME_ID='dont-starve'
GAME_ID_SHORT='dstarve'
GAME_NAME='Don’t Starve - Shipwrecked'

GAME_ARCHIVE1='gog_don_t_starve_shipwrecked_dlc_2.0.0.2.sh'
GAME_ARCHIVE1_MD5='b1d4152639a272a959d36eacf8cb859e'
GAME_ARCHIVE_FULLSIZE='1200000'
PKG_REVISION='gog2.0.0.2'

INSTALLER_PATH='data/noarch'
INSTALLER_DOC='docs/*'
INSTALLER_GAME_PKG1='game/dontstarve32/manifest_dlc0002.json'
INSTALLER_GAME_PKG2='game/dontstarve64/manifest_dlc0002.json'
INSTALLER_GAME_PKG3='game/dontstarve32/data'

APP_COMMON_ID="${GAME_ID_SHORT}-common.sh"

PKG_ID="${GAME_ID}-dlc2"
PKG_VERSION='1'
PKG_DEPS="${GAME_ID} (>= 2016.04.01)"
PKG_DESC="${GAME_NAME}
 package built from GOG.com installer
 ./play.it script version ${script_version}"

PKG1_ID="${PKG_ID}"
PKG1_ARCH='i386'
PKG1_VERSION="${PKG_VERSION}"
PKG1_CONFLICTS=''
PKG1_DEPS="${PKG_DEPS}"
PKG1_RECS=''
PKG1_DESC="${PKG_DESC}"

PKG2_ID="${PKG_ID}"
PKG2_ARCH='amd64'
PKG2_VERSION="${PKG_VERSION}"
PKG2_CONFLICTS=''
PKG2_DEPS="${PKG_DEPS}"
PKG2_RECS=''
PKG2_DESC="${PKG_DESC}"

PKG3_ID="${PKG_ID}-common"
PKG3_ARCH='all'
PKG3_VERSION="${PKG_VERSION}"
PKG3_CONFLICTS=''
PKG3_DEPS=''
PKG3_RECS=''
PKG3_DESC="${GAME_NAME} - arch-independant data
 package built from GOG.com installer
 ./play.it script version ${script_version}"

PKG1_CONFLICTS="${PKG2_ID}:${PKG2_ARCH}"
PKG2_CONFLICTS="${PKG1_ID}:${PKG1_ARCH}"

PKG1_DEPS="${PKG3_ID} (= ${PKG_VERSION}-${PKG_REVISION}), ${PKG1_DEPS}"
PKG2_DEPS="${PKG3_ID} (= ${PKG_VERSION}-${PKG_REVISION}), ${PKG2_DEPS}"

# Load common functions

TARGET_LIB_VERSION='1.13'

if [ -z "${PLAYIT_LIB}" ]; then
	PLAYIT_LIB='./play-anything.sh'
fi

if ! [ -e "${PLAYIT_LIB}" ]; then
	printf '\n\033[1;31mError:\033[0m\n'
	printf 'play-anything.sh not found.\n'
	printf 'It must be placed in the same directory than this script.\n\n'
	exit 1
fi

LIB_VERSION="$(grep '^# library version' "${PLAYIT_LIB}" | cut -d' ' -f4 | cut -d'.' -f1,2)"

if [ ${LIB_VERSION%.*} -ne ${TARGET_LIB_VERSION%.*} ] || [ ${LIB_VERSION#*.} -lt ${TARGET_LIB_VERSION#*.} ]; then
	printf '\n\033[1;31mError:\033[0m\n'
	printf 'Wrong version of play-anything.\n'
	printf 'It must be at least %s ' "${TARGET_LIB_VERSION}"
	printf 'but lower than %s.\n\n' "$((${TARGET_LIB_VERSION%.*}+1)).0"
	exit 1
fi

. "${PLAYIT_LIB}"

# Set extra variables

GAME_ARCHIVE_CHECKSUM_DEFAULT='md5sum'
PKG_COMPRESSION_DEFAULT='none'
PKG_PREFIX_DEFAULT='/usr/local'

fetch_args "$@"

set_checksum
set_compression
set_prefix

check_deps_hard ${SCRIPT_DEPS_HARD}

game_mkdir 'PKG_TMPDIR' "$(mktemp -u ${GAME_ID_SHORT}.XXXXX)" "$((${GAME_ARCHIVE_FULLSIZE}*2))"
game_mkdir 'PKG1_DIR' "${PKG1_ID}_${PKG1_VERSION}-${PKG_REVISION}_${PKG1_ARCH}" "$((${GAME_ARCHIVE_FULLSIZE}*2))"
game_mkdir 'PKG2_DIR' "${PKG2_ID}_${PKG2_VERSION}-${PKG_REVISION}_${PKG2_ARCH}" "$((${GAME_ARCHIVE_FULLSIZE}*2))"
game_mkdir 'PKG3_DIR' "${PKG3_ID}_${PKG3_VERSION}-${PKG_REVISION}_${PKG3_ARCH}" "$((${GAME_ARCHIVE_FULLSIZE}*2))"

PATH_DOC="/usr/local/share/doc/${GAME_ID}"
PATH_GAME="${PKG_PREFIX}/share/games/${GAME_ID}"

printf '\n'
set_target '1' 'gog.com'
printf '\n'

# Check target files integrity

if [ "${GAME_ARCHIVE_CHECKSUM}" = 'md5sum' ]; then
	checksum "${GAME_ARCHIVE}" 'defaults' "${GAME_ARCHIVE1_MD5}"
fi

# Extract game data

build_pkg_dirs '2' "${PATH_GAME}"
rm -rf "${PKG3_DIR}"
mkdir -p "${PKG3_DIR}/DEBIAN" "${PKG3_DIR}${PATH_DOC}" "${PKG3_DIR}${PATH_GAME}"
print wait

extract_data 'mojo' "${GAME_ARCHIVE}" "${PKG_TMPDIR}" 'fix_rights,quiet'

cd "${PKG_TMPDIR}/${INSTALLER_PATH}"
for file in ${INSTALLER_DOC}; do
	mv "${file}" "${PKG3_DIR}${PATH_DOC}"
done

for file in ${INSTALLER_GAME_PKG1}; do
  mv "${file}" "${PKG1_DIR}${PATH_GAME}"
done

for file in ${INSTALLER_GAME_PKG2}; do
  mv "${file}" "${PKG2_DIR}${PATH_GAME}"
done

for file in ${INSTALLER_GAME_PKG3}; do
	mv "${file}" "${PKG3_DIR}${PATH_GAME}"
done
cd - > /dev/null

rm -rf "${PKG_TMPDIR}"
print done

# Build package

printf '%s…\n' "$(l10n 'build_pkgs')"
print wait

write_pkg_debian "${PKG1_DIR}" "${PKG1_ID}" "${PKG1_VERSION}-${PKG_REVISION}" "${PKG1_ARCH}" "${PKG1_CONFLICTS}" "${PKG1_DEPS}" "${PKG1_RECS}" "${PKG1_DESC}" 'arch'
write_pkg_debian "${PKG2_DIR}" "${PKG2_ID}" "${PKG2_VERSION}-${PKG_REVISION}" "${PKG2_ARCH}" "${PKG2_CONFLICTS}" "${PKG2_DEPS}" "${PKG2_RECS}" "${PKG2_DESC}" 'arch'
write_pkg_debian "${PKG3_DIR}" "${PKG3_ID}" "${PKG3_VERSION}-${PKG_REVISION}" "${PKG3_ARCH}" "${PKG3_CONFLICTS}" "${PKG3_DEPS}" "${PKG3_RECS}" "${PKG3_DESC}"

build_pkg "${PKG1_DIR}" "${PKG1_DESC}" "${PKG_COMPRESSION}" 'quiet' "${PKG1_ARCH}"
build_pkg "${PKG2_DIR}" "${PKG2_DESC}" "${PKG_COMPRESSION}" 'quiet' "${PKG2_ARCH}"
build_pkg "${PKG3_DIR}" "${PKG3_DESC}" "${PKG_COMPRESSION}" 'quiet'
print done

print_instructions "$(printf '%s' "${PKG1_DESC}" | head -n1) (${PKG1_ARCH})" "${PKG3_DIR}" "${PKG1_DIR}"
printf '\n'
print_instructions "$(printf '%s' "${PKG2_DESC}" | head -n1) (${PKG2_ARCH})" "${PKG3_DIR}" "${PKG2_DIR}"
printf '\n%s ;)\n\n' "$(l10n 'have_fun')"

exit 0
