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
# Stellaris - Humanoids Species Pack
# build native packages from the original installers
# send your bug reports to contact@dotslashplay.it
###

script_version=20200427.1

# Set game-specific variables

GAME_ID='stellaris'
GAME_NAME='Stellaris - Humanoids Species Pack'

ARCHIVE_GOG='stellaris_humanoids_species_pack_2_6_3_2_37617.sh'
ARCHIVE_GOG_URL='https://www.gog.com/game/stellaris_humanoids_species_pack'
ARCHIVE_GOG_MD5='08365a3fcc021681c8d8c16f2a96020b'
ARCHIVE_GOG_SIZE='120000'
ARCHIVE_GOG_VERSION='2.6.3.2-gog37617'
ARCHIVE_GOG_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD10='stellaris_humanoids_species_pack_2_6_2_37285.sh'
ARCHIVE_GOG_OLD10_MD5='016609e948a2cdff1e8d278892573159'
ARCHIVE_GOG_OLD10_SIZE='120000'
ARCHIVE_GOG_OLD10_VERSION='2.6.2-gog37285'
ARCHIVE_GOG_OLD10_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD9='stellaris_humanoids_species_pack_2_6_1_1_36932.sh'
ARCHIVE_GOG_OLD9_MD5='1a1c595117fb7cbb37c6e84b989112d3'
ARCHIVE_GOG_OLD9_SIZE='120000'
ARCHIVE_GOG_OLD9_VERSION='2.6.1.1-gog36932'
ARCHIVE_GOG_OLD9_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD8='stellaris_humanoids_species_pack_2_6_0_4_36778.sh'
ARCHIVE_GOG_OLD8_MD5='1319f37c51e676f40708c1a9657376b2'
ARCHIVE_GOG_OLD8_SIZE='120000'
ARCHIVE_GOG_OLD8_VERSION='2.6.0.4-gog36778'
ARCHIVE_GOG_OLD8_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD7='stellaris_humanoids_species_pack_2_5_1_33517.sh'
ARCHIVE_GOG_OLD7_MD5='0832471cf232a1a5d5567258c98fa99b'
ARCHIVE_GOG_OLD7_SIZE='120000'
ARCHIVE_GOG_OLD7_VERSION='2.5.1-gog33517'
ARCHIVE_GOG_OLD7_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD6='stellaris_humanoids_species_pack_2_5_0_5_33395.sh'
ARCHIVE_GOG_OLD6_MD5='3bfe1467c1d040625de13f72eb744ce5'
ARCHIVE_GOG_OLD6_SIZE='120000'
ARCHIVE_GOG_OLD6_VERSION='2.5.0.5-gog33395'
ARCHIVE_GOG_OLD6_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD5='stellaris_humanoids_species_pack_2_4_1_1_33112.sh'
ARCHIVE_GOG_OLD5_MD5='c4ca371cdb0695d2050d70ce52e60914'
ARCHIVE_GOG_OLD5_SIZE='120000'
ARCHIVE_GOG_OLD5_VERSION='2.4.1.1-gog33112'
ARCHIVE_GOG_OLD5_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD4='stellaris_humanoids_species_pack_2_4_1_33088.sh'
ARCHIVE_GOG_OLD4_MD5='12c9649abd6f1695e2e3ddcedd2d7afc'
ARCHIVE_GOG_OLD4_SIZE='120000'
ARCHIVE_GOG_OLD4_VERSION='2.4.1-gog33088'
ARCHIVE_GOG_OLD4_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD3='stellaris_humanoids_species_pack_2_4_0_7_33057.sh'
ARCHIVE_GOG_OLD3_MD5='c2b55b152e8225959e3c1b44fdd79c44'
ARCHIVE_GOG_OLD3_SIZE='120000'
ARCHIVE_GOG_OLD3_VERSION='2.4.0.7-gog33057'
ARCHIVE_GOG_OLD3_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD2='stellaris_humanoids_species_pack_2_3_3_1_30901.sh'
ARCHIVE_GOG_OLD2_MD5='0c12e80e91ea13dd94780ca462593ac0'
ARCHIVE_GOG_OLD2_SIZE='120000'
ARCHIVE_GOG_OLD2_VERSION='2.3.3.1-gog30901'
ARCHIVE_GOG_OLD2_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD1='stellaris_humanoids_species_pack_2_3_3_30733.sh'
ARCHIVE_GOG_OLD1_MD5='4dbdb3b43bfea5a54bb17a03caae8af1'
ARCHIVE_GOG_OLD1_SIZE='120000'
ARCHIVE_GOG_OLD1_VERSION='2.3.3-gog30733'
ARCHIVE_GOG_OLD1_TYPE='mojosetup_unzip'

ARCHIVE_GOG_OLD0='stellaris_humanoids_species_pack_2_3_2_1_30253.sh'
ARCHIVE_GOG_OLD0_MD5='43492dcd83d7a43cd81593ae1a3110e4'
ARCHIVE_GOG_OLD0_SIZE='120000'
ARCHIVE_GOG_OLD0_VERSION='2.3.2.1-gog30253'
ARCHIVE_GOG_OLD0_TYPE='mojosetup_unzip'

ARCHIVE_GAME_MAIN_PATH='data/noarch/game'
ARCHIVE_GAME_MAIN_FILES='dlc/dlc018_humanoids'

PACKAGES_LIST='PKG_MAIN'

PKG_MAIN_ID="${GAME_ID}-humanoids-species-pack"
PKG_MAIN_DEPS="$GAME_ID"

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

# Build package

write_metadata
build_pkg

# Clean up

rm --recursive "$PLAYIT_WORKDIR"

# Print instructions

print_instructions

exit 0
