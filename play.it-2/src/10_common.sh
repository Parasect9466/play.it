# set package distribution-specific architecture
# USAGE: set_architecture $pkg
# CALLS: liberror set_architecture_arch set_architecture_deb set_architecture_gentoo
# NEEDED VARS: (ARCHIVE) (OPTION_PACKAGE) (PKG_ARCH)
# CALLED BY: set_temp_directories write_metadata
set_architecture() {
	use_archive_specific_value "${1}_ARCH"
	local architecture
	architecture="$(get_value "${1}_ARCH")"
	case $OPTION_PACKAGE in
		('arch')
			set_architecture_arch "$architecture"
		;;
		('deb')
			set_architecture_deb "$architecture"
		;;
		('gentoo')
			set_architecture_gentoo "$architecture"
		;;
		(*)
			liberror 'OPTION_PACKAGE' 'set_architecture'
		;;
	esac
}

# set package distribution-specific architectures
# USAGE: set_supported_architectures $pkg
# CALLS: liberror set_architecture set_architecture_gentoo
# NEEDED VARS: (ARCHIVE) (OPTION_PACKAGE) (PKG_ARCH)
# CALLED BY: write_bin write_bin_set_native_noprefix write_metadata_gentoo
set_supported_architectures() {
	case $OPTION_PACKAGE in
		('arch'|'deb')
			set_architecture "$1"
		;;
		('gentoo')
			use_archive_specific_value "${1}_ARCH"
			local architecture
			architecture="$(get_value "${1}_ARCH")"
			set_supported_architectures_gentoo "$architecture"
		;;
		(*)
			liberror 'OPTION_PACKAGE' 'set_supported_architectures'
		;;
	esac
}

# test the validity of the argument given to parent function
# USAGE: testvar $var_name $pattern
testvar() {
	test "${1%%_*}" = "$2"
}

# set defaults rights on files (755 for dirs & 644 for regular files)
# USAGE: set_standard_permissions $dir[…]
set_standard_permissions() {
	[ "$DRY_RUN" -eq 1 ] && return 0
	for dir in "$@"; do
		[  -d "$dir" ] || return 1
		find "$dir" -type d -exec chmod 755 '{}' +
		find "$dir" -type f -exec chmod 644 '{}' +
	done
}

# print OK
# USAGE: print_ok
print_ok() {
	printf '\t\033[1;32mOK\033[0m\n'
}

# print a localized error message
# USAGE: print_error
# NEEDED VARS: (LANG)
print_error() {
	local string
	case "${LANG%_*}" in
		('fr')
			string='Erreur :'
		;;
		('en'|*)
			string='Error:'
		;;
	esac
	printf '\n\033[1;31m%s\033[0m\n' "$string"
	exec 1>&2
}

# print a localized warning message
# USAGE: print_warning
# NEEDED VARS: (LANG)
print_warning() {
	local string
	case "${LANG%_*}" in
		('fr')
			string='Avertissement :'
		;;
		('en'|*)
			string='Warning:'
		;;
	esac
	printf '\n\033[1;33m%s\033[0m\n' "$string"
}

# convert files name to lower case
# USAGE: tolower $dir[…]
# CALLS: tolower_convmv tolower_shell
tolower() {
	[ "$DRY_RUN" -eq 1 ] && return 0
	for dir in "$@"; do
		[ -d "$dir" ] || return 1
		if command -v convmv > /dev/null; then
			tolower_convmv "$dir"
		else
			tolower_shell "$dir"
		fi
	done
}

# convert files name to lower case using convmv
# USAGE: tolower_convmv $dir
# CALLED BY: tolower
tolower_convmv() {
	local dir="$1"
	find "$dir" -mindepth 1 -maxdepth 1 -exec \
		convmv --notest --lower -r {} + >/dev/null 2>&1
}

# convert files name to lower case using pure shell
# USAGE: tolower_shell $dir
# CALLED BY: tolower
tolower_shell() {
	local dir="$1"

	find "$dir" -depth -mindepth 1 | while read -r file; do
		newfile="${file%/*}/$(printf '%s' "${file##*/}" | tr '[:upper:]' '[:lower:]')"
		[ -e "$newfile" ] || mv "$file" "$newfile"
	done
}

# display an error if a function has been called with invalid arguments
# USAGE: liberror $var_name $calling_function
# NEEDED VARS: (LANG)
liberror() {
	local var
	var="$1"
	local value
	value="$(get_value "$var")"
	local func
	func="$2"
	print_error
	case "${LANG%_*}" in
		('fr')
			string='Valeur incorrecte pour %s appelée par %s : %s\n'
		;;
		('en'|*)
			string='Invalid value for %s called by %s: %s\n'
		;;
	esac
	printf "$string" "$var" "$func" "$value"
	return 1
}

# get archive-specific value for a given variable name, or use default value
# USAGE: use_archive_specific_value $var_name
use_archive_specific_value() {
	[ -n "$ARCHIVE" ] || return 0
	testvar "$ARCHIVE" 'ARCHIVE' || liberror 'ARCHIVE' 'use_archive_specific_value'
	local name_real
	name_real="$1"
	local name
	name="${name_real}_${ARCHIVE#ARCHIVE_}"
	local value
	while [ "$name" != "$name_real" ]; do
		value="$(get_value "$name")"
		if [ -n "$value" ]; then
			export ${name_real?}="$value"
			return 0
		fi
		name="${name%_*}"
	done
}

# get package-specific value for a given variable name, or use default value
# USAGE: use_package_specific_value $var_name
use_package_specific_value() {
	[ -n "$PKG" ] || return 0
	testvar "$PKG" 'PKG' || liberror 'PKG' 'use_package_specific_value'
	local name_real
	name_real="$1"
	local name
	name="${name_real}_${PKG#PKG_}"
	local value
	while [ "$name" != "$name_real" ]; do
		value="$(get_value "$name")"
		if [ -n "$value" ]; then
			export ${name_real?}="$value"
			return 0
		fi
		name="${name%_*}"
	done
}

# display an error when PKG value seems invalid
# USAGE: missing_pkg_error $function_name $PKG
# NEEDED VARS: (LANG)
missing_pkg_error() {
	local string
	case "${LANG%_*}" in
		('fr')
			string='La valeur de PKG fournie à %s semble incorrecte : %s\n'
		;;
		('en'|*)
			string='The PKG value used by %s seems erroneous: %s\n'
		;;
	esac
	printf "$string" "$1" "$2"
	exit 1
}

# display a warning when PKG value is not included in PACKAGES_LIST
# USAGE: skipping_pkg_warning $function_name $PKG
# NEEDED VARS: (LANG)
skipping_pkg_warning() {
	local string
	print_warning
	case "${LANG%_*}" in
		('fr')
			string='La valeur de PKG fournie à %s ne fait pas partie de la liste de paquets à construire : %s\n'
		;;
		('en'|*)
			string='The PKG value used by %s is not part of the list of packages to build: %s\n'
		;;
	esac
	printf "$string" "$1" "$2"
}

# get the value of a variable and print it
# USAGE: get_value $variable_name
get_value() {
	local name
	local value
	name="$1"
	value="$(eval printf -- '%b' \"\$$name\")"
	printf '%s' "$value"
}

# check that the value assigned to a given option is valid
# USAGE: check_option_validity $option_name
check_option_validity() {
	local name value allowed_values
	name="$1"
	value="$(get_value "OPTION_$name")"
	allowed_values="$(get_value "ALLOWED_VALUES_$name")"
	for allowed_value in $allowed_values; do
		if [ "$value" = "$allowed_value" ]; then
			return 0
		fi
	done
	local string
	case "${LANG%_*}" in
		('fr')
			string='%s nʼest pas une valeur valide pour --%s.\n'
			string="$string"'Lancez le script avec lʼoption --%s=help pour une liste des valeurs acceptés.\n\n'
		;;
		('en'|*)
			string='%s is not a valid value for --%s.\n'
			string="$string"'Run the script with the option --%s=help to get a list of supported values.\n\n'
		;;
	esac
	print_error
	printf "$string" "$value" "$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')" "$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]')"
	return 1
}

# try to guess the tar implementation used for `tar` on the current system
# USAGE: guess_tar_implementation
guess_tar_implementation() {
	case "$(tar --version | head --lines 1)" in
		(*'GNU tar'*)
			PLAYIT_TAR_IMPLEMENTATION='gnutar'
		;;
		(*'libarchive'*)
			PLAYIT_TAR_IMPLEMENTATION='bsdtar'
		;;
		(*)
			error_unknown_tar_implementation
		;;
	esac
}
