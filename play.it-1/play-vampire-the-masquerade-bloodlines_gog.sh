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
# conversion script for the Vampire the Masquerade: Bloodlines installer sold on GOG
# build a .deb package from the Windows installer
#
# send your bug reports to vv221@dotslashplay.it
###

script_version=20170726.1

# Set game-specific variables

SCRIPT_DEPS_HARD='fakeroot innoextract'
SCRIPT_DEPS_SOFT='icotool wrestool'

GAME_ID='vampire-the-masquerade-bloodlines'
GAME_ID_SHORT='bloodlines'
GAME_NAME='Vampire: The Masquerade - Bloodlines'

GAME_ARCHIVE1='setup_vtmb_1.2_(up_9.7_basic)_(11362).exe'
GAME_ARCHIVE1_MD5='62b8db3b054595fb46bd8eaa5f8ae7bc'
GAME_ARCHIVE1_FILE2='setup_vtmb_1.2_(up_9.7_basic)_(11362)-1.bin'
GAME_ARCHIVE1_FILE2_MD5='4177042d5a6e03026d52428e900e6137'
GAME_ARCHIVE_FULLSIZE='4100000'
PKG_REVISION='gog11362'

INSTALLER_PATH='app'
INSTALLER_JUNK='./goggame-* ./webcache.zip'
INSTALLER_DOC='./*.pdf ./*.txt docs/*'
INSTALLER_GAME='./*'

GAME_CACHE_DIRS=''
GAME_CACHE_FILES=''
GAME_CACHE_FILES_POST='unofficial_patch/*.tmp vampire/*.tmp'
GAME_CONFIG_DIRS='unofficial_patch/cfg vampire/cfg'
GAME_CONFIG_FILES=''
GAME_CONFIG_FILES_POST='unofficial_patch/vidcfg.bin vampire/vidcfg.bin'
GAME_DATA_DIRS='unofficial_patch/maps/graphs unofficial_patch/python unofficial_patch/save vampire/maps/graphs vampire/python vampire/save'
GAME_DATA_FILES=''
GAME_DATA_FILES_POST=''

APP_COMMON_ID="${GAME_ID_SHORT}-common.sh"

APP1_ID="${GAME_ID}"
APP1_EXE='./vampire.exe'
APP1_EXE_OPTIONS='-game unofficial_patch'
APP1_ICON='./vampire.exe'
APP1_ICON_RES='32x32'
APP1_NAME="${GAME_NAME} (Unofficial Patch 9.7)"
APP1_NAME_FR="${GAME_NAME} (Unofficial Patch 9.7)"
APP1_CAT='Game'

APP2_ID="${GAME_ID}_vanilla"
APP2_EXE='./vampire.exe'
APP2_NAME="${GAME_NAME} (vanilla 1.2)"
APP2_NAME_FR="${GAME_NAME} (vanilla 1.2)"
APP2_CAT='Game'

PKG1_ID="${GAME_ID}"
PKG1_VERSION='1.2'
PKG1_ARCH='i386'
PKG1_CONFLICTS=''
PKG1_DEPS='wine:amd64 | wine, wine32 | wine-bin | wine1.6-i386 | wine1.4-i386 | wine-staging-i386'
PKG1_RECS=''
PKG1_DESC="${GAME_NAME}
 package built from GOG.com Windows installer
 ./play.it script version ${script_version}"

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

NO_ICON=0

GAME_ARCHIVE_CHECKSUM_DEFAULT='md5sum'
PKG_COMPRESSION_DEFAULT='none'
PKG_PREFIX_DEFAULT='/usr/local'

fetch_args "$@"

set_checksum
set_compression
set_prefix

check_deps_hard ${SCRIPT_DEPS_HARD}
check_deps_soft ${SCRIPT_DEPS_SOFT}

game_mkdir 'PKG_TMPDIR' "$(mktemp -u ${GAME_ID_SHORT}.XXXXX)" "$((${GAME_ARCHIVE_FULLSIZE}*2))"
game_mkdir 'PKG1_DIR' "${PKG1_ID}_${PKG1_VERSION}-${PKG_REVISION}_${PKG1_ARCH}" "$((${GAME_ARCHIVE_FULLSIZE}*2))"

PATH_BIN="${PKG_PREFIX}/games"
PATH_DESK='/usr/local/share/applications'
PATH_DOC="${PKG_PREFIX}/share/doc/${GAME_ID}"
PATH_GAME="${PKG_PREFIX}/share/games/${GAME_ID}"
PATH_ICON_BASE='/usr/local/share/icons/hicolor'

printf '\n'
set_target '1' 'gog.com'
set_target_extra 'GAME_ARCHIVE1_FILE2' '' "${GAME_ARCHIVE1_FILE2}"
printf '\n'

# Check target file integrity

if [ "${GAME_ARCHIVE_CHECKSUM}" = 'md5sum' ]; then
	printf '%s…\n' "$(l10n 'checksum_multiple')"
	checksum "${GAME_ARCHIVE}" 'quiet' "${GAME_ARCHIVE1_MD5}"
	checksum "${GAME_ARCHIVE1_FILE2}" 'quiet' "${GAME_ARCHIVE1_FILE2_MD5}"
	print done
fi

# Extract game data

build_pkg_dirs '1' "${PATH_BIN}" "${PATH_DOC}" "${PATH_DESK}" "${PATH_GAME}"
print wait

extract_data 'inno' "${GAME_ARCHIVE}" "${PKG_TMPDIR}" 'quiet'

cd "${PKG_TMPDIR}/${INSTALLER_PATH}"
for file in ${INSTALLER_JUNK}; do
	rm -rf "${file}"
done

for file in ${INSTALLER_DOC}; do
	mv "${file}" "${PKG1_DIR}${PATH_DOC}"
done
rmdir docs

for file in ${INSTALLER_GAME}; do
	mv "${file}" "${PKG1_DIR}${PATH_GAME}"
done
cd - 1>/dev/null

if [ "${NO_ICON}" = '0' ]; then
	extract_icons "${APP1_ID}" "${APP1_ICON}" "${APP1_ICON_RES}" "${PKG_TMPDIR}"
fi

rm -rf "${PKG_TMPDIR}"
print done

# Write launchers

write_bin_wine_common "${PKG1_DIR}${PATH_BIN}/${APP_COMMON_ID}"
write_bin_wine_cfg "${PKG1_DIR}${PATH_BIN}/${GAME_ID_SHORT}-winecfg"
write_bin_wine "${PKG1_DIR}${PATH_BIN}/${APP1_ID}" "${APP1_EXE}" "${APP1_EXE_OPTIONS}" '' "${APP1_NAME}"
write_bin_wine "${PKG1_DIR}${PATH_BIN}/${APP2_ID}" "${APP2_EXE}" '' '' "${APP2_NAME}"

write_desktop "${APP1_ID}" "${APP1_NAME}" "${APP1_NAME_FR}" "${PKG1_DIR}${PATH_DESK}/${APP1_ID}.desktop" "${APP1_CAT}" 'wine'
write_desktop "${APP2_ID}" "${APP2_NAME}" "${APP2_NAME_FR}" "${PKG1_DIR}${PATH_DESK}/${APP2_ID}.desktop" "${APP2_CAT}" 'wine'
printf '\n'

# Build package

write_pkg_debian "${PKG1_DIR}" "${PKG1_ID}" "${PKG1_VERSION}-${PKG_REVISION}" "${PKG1_ARCH}" "${PKG1_CONFLICTS}" "${PKG1_DEPS}" "${PKG1_RECS}" "${PKG1_DESC}"

if [ "${NO_ICON}" = '0' ]; then
	file="${PKG1_DIR}/DEBIAN/postinst"
	cat > "${file}" <<- EOF
	#!/bin/sh -e
	for res in ${APP1_ICON_RES}; do
	  path_icon="${PATH_ICON_BASE}/\${res}/apps"
	  ln -s "./${APP1_ID}.png" "\${path_icon}/${APP2_ID}.png"
	done
	exit 0
	EOF
	sed -i 's/  /\t/' "${file}"
	chmod 755 "${file}"

	file="${PKG1_DIR}/DEBIAN/prerm"
	cat > "${file}" <<- EOF
	#!/bin/sh -e
	for res in ${APP1_ICON_RES}; do
	  path_icon="${PATH_ICON_BASE}/\${res}/apps"
	  rm -f "\${path_icon}/${APP2_ID}.png"
	done
	exit 0
	EOF
	sed -i 's/  /\t/' "${file}"
	chmod 755 "${file}"
fi

build_pkg "${PKG1_DIR}" "${PKG1_DESC}" "${PKG_COMPRESSION}"

print_instructions "${PKG1_DESC}" "${PKG1_DIR}"
printf '\n%s ;)\n\n' "$(l10n 'have_fun')"

exit 0
