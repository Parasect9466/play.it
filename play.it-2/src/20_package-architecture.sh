# select package architecture to build
# USAGE: select_package_architecture
# NEEDED_VARS: OPTION_ARCHITECTURE PACKAGES_LIST
select_package_architecture() {
	[ "$OPTION_ARCHITECTURE" = 'all' ] && return 0
	local version_major_target
	local version_minor_target
	# shellcheck disable=SC2154
	version_major_target="${target_version%%.*}"
	# shellcheck disable=SC2154
	version_minor_target=$(printf '%s' "$target_version" | cut --delimiter='.' --fields=2)
	if [ $version_major_target -lt 2 ] || [ $version_minor_target -lt 6 ]; then
		warning_option_not_supported '--architecture'
		OPTION_ARCHITECTURE='all'
		export OPTION_ARCHITECTURE
		return 0
	fi
	if [ "$OPTION_ARCHITECTURE" = 'auto' ]; then
		case "$(uname --machine)" in
			('i686')
				OPTION_ARCHITECTURE='32'
			;;
			('x86_64')
				OPTION_ARCHITECTURE='64'
			;;
			(*)
				select_package_architecture_warning_unknown
				OPTION_ARCHITECTURE='all'
				export OPTION_ARCHITECTURE
				return 0
			;;
		esac
		export OPTION_ARCHITECTURE
		select_package_architecture
		return 0
	fi
	local package_arch
	local packages_list_32
	local packages_list_64
	local packages_list_all
	for package in $PACKAGES_LIST; do
		package_arch="$(get_value "${package}_ARCH")"
		case "$package_arch" in
			('32')
				packages_list_32="$packages_list_32 $package"
			;;
			('64')
				packages_list_64="$packages_list_64 $package"
			;;
			(*)
				packages_list_all="$packages_list_all $package"
			;;
		esac
	done
	case "$OPTION_ARCHITECTURE" in
		('32')
			if [ -z "$packages_list_32" ]; then
				warning_architecture_not_available "$OPTION_ARCHITECTURE"
				OPTION_ARCHITECTURE='all'
				return 0
			fi
			PACKAGES_LIST="$packages_list_32 $packages_list_all"
		;;
		('64')
			if [ -z "$packages_list_64" ]; then
				warning_architecture_not_available "$OPTION_ARCHITECTURE"
				OPTION_ARCHITECTURE='all'
				return 0
			fi
			PACKAGES_LIST="$packages_list_64 $packages_list_all"
		;;
		(*)
			error_architecture_not_supported "$OPTION_ARCHITECTURE"
		;;
	esac
	export PACKAGES_LIST
}

