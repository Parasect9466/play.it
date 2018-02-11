# write package meta-data
# USAGE: write_metadata [$pkg…]
# NEEDED VARS: (ARCHIVE) GAME_NAME (OPTION_PACKAGE) PACKAGES_LIST (PKG_ARCH) PKG_DEPS_ARCH PKG_DEPS_DEB PKG_DESCRIPTION PKG_ID (PKG_PATH) PKG_PROVIDE PKG_VERSION
# CALLS: liberror pkg_write_arch pkg_write_deb set_architecture testvar
write_metadata() {
	if [ $# = 0 ]; then
		write_metadata $PACKAGES_LIST
		return 0
	fi
	local pkg_architecture
	local pkg_description
	local pkg_id
	local pkg_maint
	local pkg_path
	local pkg_provide
	for pkg in "$@"; do
		testvar "$pkg" 'PKG' || liberror 'pkg' 'write_metadata'

		# Set package-specific variables
		set_architecture "$pkg"
		pkg_id="$(eval printf -- '%b' \"\$${pkg}_ID\")"
		pkg_maint="$(whoami)@$(hostname)"
		pkg_path="$(eval printf -- '%b' \"\$${pkg}_PATH\")"
		[ -n "$pkg_path" ] || missing_pkg_error 'write_metadata' "$PKG"
		pkg_provide="$(eval printf -- '%b' \"\$${pkg}_PROVIDE\")"

		use_archive_specific_value "${pkg}_DESCRIPTION"
		pkg_description="$(eval printf -- '%b' \"\$${pkg}_DESCRIPTION\")"

		if [ "$(eval printf -- '%b' \"\$${pkg}_VERSION\")" ]; then
			pkg_version="$(eval printf -- '%b' \"\$${pkg}_VERSION\")"
		else
			pkg_version="$PKG_VERSION"
		fi

		case $OPTION_PACKAGE in
			('arch')
				pkg_write_arch
			;;
			('deb')
				pkg_write_deb
			;;
			(*)
				liberror 'OPTION_PACKAGE' 'write_metadata'
			;;
		esac
	done
	rm  --force "$postinst" "$prerm"
}

# build .pkg.tar or .deb package
# USAGE: build_pkg [$pkg…]
# NEEDED VARS: (OPTION_COMPRESSION) (LANG) (OPTION_PACKAGE) PACKAGES_LIST (PKG_PATH) PLAYIT_WORKDIR
# CALLS: liberror pkg_build_arch pkg_build_deb testvar
build_pkg() {
	if [ $# = 0 ]; then
		build_pkg $PACKAGES_LIST
		return 0
	fi
	local pkg_path
	for pkg in "$@"; do
		testvar "$pkg" 'PKG' || liberror 'pkg' 'build_pkg'
		pkg_path="$(eval printf -- '%b' \"\$${pkg}_PATH\")"
		[ -n "$pkg_path" ] || missing_pkg_error 'build_pkg' "$PKG"
		case $OPTION_PACKAGE in
			('arch')
				pkg_build_arch "$pkg_path"
			;;
			('deb')
				pkg_build_deb "$pkg_path"
			;;
			(*)
				liberror 'OPTION_PACKAGE' 'build_pkg'
			;;
		esac
	done
}

# print package building message
# USAGE: pkg_print $file
# NEEDED VARS: (LANG)
# CALLED BY: pkg_build_arch pkg_build_deb
pkg_print() {
	local string
	case "${LANG%_*}" in
		('fr')
			string='Construction de %s'
		;;
		('en'|*)
			string='Building %s'
		;;
	esac
	printf "$string" "$1"
}

# print package building message
# USAGE: pkg_build_print_already_exists $file
# NEEDED VARS: (LANG)
# CALLED BY: pkg_build_arch pkg_build_deb
pkg_build_print_already_exists() {
	local string
	case "${LANG%_*}" in
		('fr')
			string='%s existe déjà.\n'
		;;
		('en'|*)
			string='%s already exists.\n'
		;;
	esac
	printf "$string" "$1"
}

