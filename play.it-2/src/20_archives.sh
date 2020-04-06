# set main archive for data extraction
# USAGE: archive_set_main $archive[…]
# CALLS: archive_set archive_set_error_not_found
archive_set_main() {
	archive_set 'SOURCE_ARCHIVE' "$@"
	[ -n "$SOURCE_ARCHIVE" ] || archive_set_error_not_found "$@"
}

# set a single archive for data extraction
# USAGE: archive_set $name $archive[…]
# CALLS: archive_get_infos archive_check_for_extra_parts
archive_set() {
	local archive
	local current_value
	local file
	local name
	name=$1
	shift 1
	current_value="$(get_value "$name")"
	if [ -n "$current_value" ]; then
		for archive in "$@"; do
			file="$(get_value "$archive")"
			if [ "$(basename "$current_value")" = "$file" ]; then
				archive_get_infos "$archive" "$name" "$current_value"
				archive_check_for_extra_parts "$archive" "$name"
				ARCHIVE="$archive"
				export ARCHIVE
				return 0
			fi
		done
	else
		for archive in "$@"; do
			file="$(get_value "$archive")"
			if [ ! -f "$file" ] && [ -n "$SOURCE_ARCHIVE" ] && [ -f "${SOURCE_ARCHIVE%/*}/$file" ]; then
				file="${SOURCE_ARCHIVE%/*}/$file"
			fi
			if [ -f "$file" ]; then
				archive_get_infos "$archive" "$name" "$file"
				archive_check_for_extra_parts "$archive" "$name"
				ARCHIVE="$archive"
				export ARCHIVE
				return 0
			fi
		done
	fi
	unset $name
}

# automatically check for presence of archives using the name of the base archive with a _PART1 to _PART9 suffix appended
# returns an error if such an archive is set by the script but not found
# returns success on the first archive not set by the script
# USAGE: archive_check_for_extra_parts $archive $name
# NEEDED_VARS: (LANG) (SOURCE_ARCHIVE)
# CALLS: set_archive
archive_check_for_extra_parts() {
	local archive
	local file
	local name
	local part_archive
	local part_name
	archive="$1"
	name="$2"
	for i in $(seq 1 9); do
		part_archive="${archive}_PART${i}"
		part_name="${name}_PART${i}"
		file="$(get_value "$part_archive")"
		[ -n "$file" ] || return 0
		set_archive "$part_name" "$part_archive"
		if [ -z "$(get_value "$part_name")" ]; then
			set_archive_error_not_found "$part_archive"
		fi
	done
}

# get informations about a single archive and export them
# USAGE: archive_get_infos $archive $name $file
# CALLS: archive_guess_type archive_integrity_check archive_print_file_in_use check_deps
# CALLED BY: archive_set
archive_get_infos() {
	local file
	local md5
	local name
	local size
	local type
	ARCHIVE="$1"
	name="$2"
	file="$3"
	archive_print_file_in_use "$file"
	eval $name=\"$file\"
	md5="$(get_value "${ARCHIVE}_MD5")"
	type="$(get_value "${ARCHIVE}_TYPE")"
	size="$(get_value "${ARCHIVE}_SIZE")"
	[ -n "$md5" ] && archive_integrity_check "$ARCHIVE" "$file"
	if [ -z "$type" ]; then
		archive_guess_type "$ARCHIVE" "$file"
		type="$(get_value "${ARCHIVE}_TYPE")"
	fi
	eval ${name}_TYPE=\"$type\"
	export ${name?}_TYPE
	check_deps
	if [ -n "$size" ]; then
		[ -n "$ARCHIVE_SIZE" ] || ARCHIVE_SIZE='0'
		ARCHIVE_SIZE="$((ARCHIVE_SIZE + size))"
	fi
	export ARCHIVE_SIZE
	export PKG_VERSION
	export ${name?}
	export ARCHIVE
}

# try to guess archive type from file name
# USAGE: archive_guess_type $archive $file
# CALLS: archive_guess_type_error
# CALLED BY: archive_get_infos
archive_guess_type() {
	local archive
	local file
	local type
	archive="$1"
	file="$2"
	case "${file##*/}" in
		(*'.cab')
			type='cabinet'
		;;
		(*'.deb')
			type='debian'
		;;
		('setup_'*'.exe'|'patch_'*'.exe')
			type='innosetup'
		;;
		('gog_'*'.sh')
			type='mojosetup'
		;;
		(*'.iso')
			type='iso'
		;;
		(*'.msi')
			type='msi'
		;;
		(*'.rar')
			type='rar'
		;;
		(*'.tar')
			type='tar'
		;;
		(*'.tar.gz'|*'.tgz')
			type='tar.gz'
		;;
		(*'.zip')
			type='zip'
		;;
		(*'.7z')
			type='7z'
		;;
		(*)
			archive_guess_type_error "$archive"
		;;
	esac
	eval ${archive}_TYPE=\'$type\'
	export ${archive?}_TYPE
}

# check integrity of target file
# USAGE: archive_integrity_check $archive $file
# CALLS: archive_integrity_check_md5 liberror
archive_integrity_check() {
	local archive
	local file
	archive="$1"
	file="$2"
	case "$OPTION_CHECKSUM" in
		('md5')
			archive_integrity_check_md5 "$archive" "$file"
			print_ok
		;;
		('none')
			return 0
		;;
		(*)
			liberror 'OPTION_CHECKSUM' 'archive_integrity_check'
		;;
	esac
}

# check integrity of target file against MD5 control sum
# USAGE: archive_integrity_check_md5 $archive $file
# CALLS: archive_integrity_check_print archive_integrity_check_error
# CALLED BY: archive_integrity_check
archive_integrity_check_md5() {
	local archive
	local file
	archive="$1"
	file="$2"
	archive_integrity_check_print "$file"
	archive_sum="$(get_value "${ARCHIVE}_MD5")"
	file_sum="$(md5sum "$file" | awk '{print $1}')"
	[ "$file_sum" = "$archive_sum" ] || archive_integrity_check_error "$file"
}

# get list of available archives, exported as ARCHIVES_LIST
# USAGE: archives_get_list
archives_get_list() {
	local script
	[ -n "$ARCHIVES_LIST" ] && return 0
	script="$0"
	while read -r archive; do
		if [ -z "$ARCHIVES_LIST" ]; then
			ARCHIVES_LIST="$archive"
		else
			ARCHIVES_LIST="$ARCHIVES_LIST $archive"
		fi
	done <<- EOL
	$(grep --regexp='^ARCHIVE_[^_]\+=' --regexp='^ARCHIVE_[^_]\+_OLD=' --regexp='^ARCHIVE_[^_]\+_OLD[^_]\+=' "$script" | sed 's/\([^=]\)=.\+/\1/')
	EOL
	export ARCHIVES_LIST
}

