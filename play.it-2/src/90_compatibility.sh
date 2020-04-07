# Keep compatibility with 2.11 and older

liberror() {
	error_invalid_argument "$1" "$2"
}

skipping_pkg_warning() {
	warning_skip_package "$1" "$2"
}

archive_set_error_not_found() {
	error_archive_not_found "$@"
}

archive_guess_type_error() {
	error_archive_type_not_set "$1"
}

archive_print_file_in_use() {
	information_file_in_use "$1"
}

archive_integrity_check_error() {
	error_hashsum_mismatch "$1"
}

select_package_architecture_warning_unavailable() {
	warning_architecture_not_available "$OPTION_ARCHITECTURE"
}

select_package_architecture_error_unknown() {
	error_architecture_not_supported "$OPTION_ARCHITECTURE"
}

select_package_architecture_warning_unsupported() {
	warning_option_not_supported '--architecture'
}

error_no_pkg() {
	error_variable_not_set "$1" '$PKG'
}

set_temp_directories_error_no_size() {
	error_variable_not_set 'set_temp_directories' '$ARCHIVE_SIZE'
}

prepare_package_layout_error_no_list() {
	error_variable_not_set 'prepare_package_layout' '$PACKAGES_LIST'
}

organize_data_error_missing_pkg() {
	error_variable_not_set 'organize_data' '$PKG'
}

icon_path_empty_error() {
	error_variable_not_set 'icons_get_from_path' '$'"$1"
}

set_temp_directories_error_not_enough_space() {
	error_not_enough_free_space "$XDG_RUNTIME_DIR" "$(get_tmp_dir)" "$XDG_CACHE_HOME" "$PWD"
}

archive_extraction_innosetup_error_version() {
	error_innoextract_version_too_old "$1"
}

icon_file_not_found_error() {
	error_icon_file_not_found "$1"
}

missing_pkg_error() {
	error_invalid_argument 'PKG' "$1"
}

pkg_build_print_already_exists() {
	information_package_already_exists "$1"
}

archive_integrity_check_print() {
	information_file_integrity_check "$1"
}

extract_data_from_print() {
	information_archive_data_extraction "$1"
}

pkg_print() {
	information_package_building "$1"
}

# Keep compatibility with 2.10 and older

write_bin() {
	local application
	for application in "$@"; do
		launcher_write_script "$application"
	done
}

write_desktop() {
	local application
	for application in "$@"; do
		launcher_write_desktop "$application"
	done
}

write_desktop_winecfg() {
	launcher_write_desktop 'APP_WINECFG'
}

write_launcher() {
	launchers_write "$@"
}

# Keep compatibility with 2.7 and older

extract_and_sort_icons_from() {
	icons_get_from_package "$@"
}

extract_icon_from() {
	local destination
	local file
	destination="$PLAYIT_WORKDIR/icons"
	mkdir --parents "$destination"
	for file in "$@"; do
		extension="${file##*.}"
		case "$extension" in
			('exe')
				icon_extract_ico_from_exe "$file" "$destination"
			;;
			(*)
				icon_extract_png_from_file "$file" "$destination"
			;;
		esac
	done
}

get_icon_from_temp_dir() {
	icons_get_from_workdir "$@"
}

move_icons_to() {
	icons_move_to "$@"
}

postinst_icons_linking() {
	icons_linking_postinst "$@"
}

# Keep compatibility with 2.6.0 and older

set_archive() {
	archive_set "$@"
}

set_archive_error_not_found() {
	archive_set_error_not_found "$@"
}
