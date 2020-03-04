# write launcher script
# USAGE: launcher_write_script $app
# NEEDED VARS: GAME_ID OPTION_ARCHITECTURE PACKAGES_LIST PATH_BIN
# CALLS: error_missing_argument error_extra_arguments testvar liberror error_no_pkg skipping_pkg_warning missing_pkg_error launcher_write_script_headers launcher_write_script_prefix_functions launcher_write_script_wine_winecfg launcher_write_script_dosbox_application_variables launcher_write_script_native_application_variables launcher_write_script_scummvm_application_variables launcher_write_script_wine_application_variables launcher_write_script_prefix_functions launcher_write_script_prefix_build launcher_write_script_wine_prefix_build launcher_write_script_dosbox_run launcher_write_script_native_run launcher_write_script_nativenoprefix_run launcher_write_script_scummvm_run launcher_write_script_winecfg_run launcher_write_script_wine_run error_launcher_missing_binary
# CALLED BY:
launcher_write_script() {
	# check that this has been called with exactly one argument
	if [ "$#" -eq 0 ]; then
		error_missing_argument 'launcher_write_script'
	elif [ "$#" -gt 1 ]; then
		error_extra_arguments 'launcher_write_script'
	fi

	# check that $PKG is set
	if [ -z "$PKG" ]; then
		error_no_pkg 'launcher_write_script'
	fi

	# skip any action if called for a package excluded for target architectures
	if [ "$OPTION_ARCHITECTURE" != 'all' ] && [ -n "${PACKAGES_LIST##*$PKG*}" ]; then
		skipping_pkg_warning 'launcher_write_script' "$PKG"
		return 0
	fi

	# parse argument
	local application
	application="$1"
	testvar "$application" 'APP' || liberror 'application' 'launcher_write_script'

	# get application type
	local application_type
	application_type="$(get_value "${application}_TYPE")"

	# compute file name and path
	local application_id
	local package_path
	local target_file
	package_path="$(get_value "${PKG}_PATH")"
	[ -n "$package_path" ] || missing_pkg_error 'launcher_write_script' "$PKG"
	application_id="$(get_value "${application}_ID")"
	if [ -z "$application_id" ]; then
		application_id="$GAME_ID"
	fi
	target_file="${package_path}${PATH_BIN}/$application_id"

	# Check that the launcher target exists
	local binary_file binary_path
	case "$application_type" in
		('scummvm')
			# ScummVM games do not rely on a provided binary
		;;
		('wine')
			use_package_specific_value "${application}_EXE"
			binary_file=$(get_value "${application}_EXE")
			if [ "$binary_file" != 'winecfg' ]; then
				binary_path="${package_path}${PATH_GAME}/$binary_file"
				if \
					[ $DRY_RUN -eq 0 ] && \
					[ ! -f "$binary_path" ]
				then
					error_launcher_missing_binary "$binary_path"
				fi
			fi
		;;
		(*)
			use_package_specific_value "${application}_EXE"
			binary_file=$(get_value "${application}_EXE")
			binary_path="${package_path}${PATH_GAME}/$binary_file"
			if \
				[ $DRY_RUN -eq 0 ] && \
				[ ! -f "$binary_path" ]
			then
				error_launcher_missing_binary "$binary_path"
			fi
		;;
	esac

	# if called in dry run mode, return before writing anything
	if [ "$DRY_RUN" -eq 1 ]; then
		return 0
	fi

	# write launcher script
	mkdir --parents "$(dirname "$target_file")"
	touch "$target_file"
	chmod 755 "$target_file"
	launcher_write_script_headers "$target_file"
	case "$application_type" in
		('dosbox')
			launcher_write_script_dosbox_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_user_files "$target_file"
			launcher_write_script_prefix_variables "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			launcher_write_script_prefix_build "$target_file"
			launcher_write_script_dosbox_run "$application" "$target_file"
			launcher_write_script_prefix_cleanup "$target_file"
		;;
		('java')
			launcher_write_script_java_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_user_files "$target_file"
			launcher_write_script_prefix_variables "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			launcher_write_script_prefix_build "$target_file"
			launcher_write_script_java_run "$application" "$target_file"
			launcher_write_script_prefix_cleanup "$target_file"
		;;
		('native')
			launcher_write_script_native_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_user_files "$target_file"
			launcher_write_script_prefix_variables "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			launcher_write_script_prefix_build "$target_file"
			launcher_write_script_native_run "$application" "$target_file"
			launcher_write_script_prefix_cleanup "$target_file"
		;;
		('native_no-prefix')
			launcher_write_script_native_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_nativenoprefix_run "$application" "$target_file"
		;;
		('scummvm')
			launcher_write_script_scummvm_application_variables "$application" "$target_file"
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_scummvm_run "$application" "$target_file"
		;;
		('wine')
			if [ "$application_id" != "${GAME_ID}_winecfg" ]; then
				launcher_write_script_wine_application_variables "$application" "$target_file"
			fi
			launcher_write_script_game_variables "$target_file"
			launcher_write_script_user_files "$target_file"
			launcher_write_script_prefix_variables "$target_file"
			launcher_write_script_prefix_functions "$target_file"
			launcher_write_script_wine_prefix_build "$target_file"
			if [ "$application_id" = "${GAME_ID}_winecfg" ]; then
				launcher_write_script_winecfg_run "$target_file"
			else
				launcher_write_script_wine_run "$application" "$target_file"
			fi
			launcher_write_script_prefix_cleanup "$target_file"
		;;
		(*)
			error_unknown_application_type "$application_type"
		;;
	esac
	cat >> "$target_file" <<- 'EOF'
	exit 0
	EOF

	# for native applications, add execution permissions to the game binary file
	case "$application_type" in
		('native'*)
			local application_exe
			use_package_specific_value "${application}_EXE"
			application_exe="$(get_value "${application}_EXE")"
			chmod +x "${package_path}${PATH_GAME}/$application_exe"
		;;
	esac

	# for WINE applications, write launcher script for winecfg
	case "$application_type" in
		('wine')
			local winecfg_file
			winecfg_file="${package_path}${PATH_BIN}/${GAME_ID}_winecfg"
			if [ ! -e "$winecfg_file" ]; then
				launcher_write_script_wine_winecfg "$application"
			fi
		;;
	esac

	return 0
}

# write launcher script headers
# USAGE: launcher_write_script_headers $file
# NEEDED VARS: library_version
# CALLED BY: launcher_write_script
launcher_write_script_headers() {
	local file
	file="$1"
	cat > "$file" <<- EOF
	#!/bin/sh
	# script generated by ./play.it $library_version - http://wiki.dotslashplay.it/
	set -o errexit

	EOF
	return 0
}

# write launcher script game-specific variables
# USAGE: launcher_write_script_game_variables $file
# NEEDED VARS: GAME_ID PATH_GAME
# CALLED BY: launcher_write_script
launcher_write_script_game_variables() {
	local file
	file="$1"
	cat >> "$file" <<- EOF
	# Set game-specific values

	GAME_ID='$GAME_ID'
	PATH_GAME='$PATH_GAME'

	EOF
	return 0
}

# write launcher script list of user-writable files
# USAGE: launcher_write_script_user_files $file
# NEEDED VARS: CONFIG_DIRS CONFIG_FILES DATA_DIRS DATA_FILES
# CALLED BY: launcher_write_script
launcher_write_script_user_files() {
	local file
	file="$1"
	cat >> "$file" <<- EOF
	# Set list of user-writable files

	CONFIG_DIRS='$CONFIG_DIRS'
	CONFIG_FILES='$CONFIG_FILES'
	DATA_DIRS='$DATA_DIRS'
	DATA_FILES='$DATA_FILES'

	EOF
	return 0
}

# write launcher script prefix-related variables
# USAGE: launcher_write_script_prefix_variables $file
# CALLED BY: launcher_write_script
launcher_write_script_prefix_variables() {
	local file
	file="$1"
	cat >> "$file" <<- 'EOF'
	# Set prefix-related values

	: "${PREFIX_ID:="$GAME_ID"}"
	PATH_CONFIG="${XDG_CONFIG_HOME:="$HOME/.config"}/$PREFIX_ID"
	PATH_DATA="${XDG_DATA_HOME:="$HOME/.local/share"}/games/$PREFIX_ID"

	EOF
	return 0
}

# write launcher script prefix functions
# USAGE: launcher_write_script_prefix_functions $file
# CALLED BY: launcher_write_script
launcher_write_script_prefix_functions() {
	local file
	file="$1"
	cat >> "$file" <<- 'EOF'
	# Set localization and error reporting functions

	# select strings matching the current locale
	# strings must be prefixed by a two-letter language code and a colon
	# USAGE: localize $string[…]
	localize() {
	    local lang
	    local string
	    local match
	    for lang in "${LANG%%_*}" 'en'; do
	        for string in "$@"; do
	            if [ "${string%%:*}" = "$lang" ]; then
	                echo "${string#*:}"
	                match=1
	            fi
	        done
	        if [ "$match" ]; then
	            break
	        fi
	    done
	}

	# print a localized message on standard error output
	# strings must be prefixed by a two-letter language code and a colon
	# USAGE: display_message $string[…]
	display_message() {
	    local string
	    localize "$@" | while read -r string; do
	        printf "$string\n"
	    done 1>&2
	}

	# print a localized error message on standard error output
	# strings must be prefixed by a two-letter language code and a colon
	# USAGE: display_error $string[…]
	display_error() {
	    display_message \
	        'en:\033[1;31mError:\033[0m' \
	        'fr:\033[1;31mErreur :\033[0m'
	    display_message "$@"
	}

	# print a localized warning message on standard error output
	# strings must be prefixed by a two-letter language code and a colon
	# USAGE: display_warning $string[…]
	display_warning() {
	    display_message \
	        'en:\033[1;33mWarning:\033[0m' \
	        'fr:\033[1;33mAvertissement :\033[0m'
	    display_message "$@"
	}

	# Set prefix-related functions

	# create prefix and user config/data directories
	# USAGE: prefix_create_dirs
	prefix_create_dirs() {
	    for dir in "$PATH_PREFIX" "$PATH_CONFIG" "$PATH_DATA"; do
	        if [ ! -d "$dir" ]; then
	            mkdir --parents "$dir"
	        fi
	    done
	}

	# populate prefix with symbolic links to all game file
	# USAGE: prefix_init_game_files
	prefix_init_game_files() {
	    # remove symlinks to game directories
	    (
	        cd "$PATH_GAME"
	        find . -type d | while read -r dir; do
	            if [ -h "$PATH_PREFIX/$dir" ]; then
	                rm "$PATH_PREFIX/$dir"
	            fi
	        done
	    )
	    # populate prefix with symlinks to all game file
	    cp --recursive --remove-destination --symbolic-link --no-target-directory "$PATH_GAME" "$PATH_PREFIX"
	    # remove dangling links and non-game empty directories
	    (
	        cd "$PATH_PREFIX"
	        find . -type l | while read -r link; do
	            if [ ! -e "$link" ]; then
	                rm "$link"
	            fi
	        done
	        find . -depth -type d | while read -r dir; do
	            if [ ! -e "$PATH_GAME/$dir" ]; then
	                rmdir --ignore-fail-on-non-empty "$dir"
	            fi
	        done
	    )
	}

	# create symbolic link $PATH_PREFIX/$target -> $userdir/$target,
	# overwriting $PATH_PREFIX/$target if it exists
	# USAGE: prefix_symlink_to_userdir $userdir $target
	prefix_symlink_to_userdir() {
	    local userdir
	    local target
	    local target_prefix
	    local target_real
	    userdir="$1"
	    target="$2"
	    if [ -e "$PATH_PREFIX/$target" ]; then
	        target_prefix="$(readlink --canonicalize-existing "$PATH_PREFIX/$target")"
	    else
	        unset target_prefix
	    fi
	    target_real="$(readlink --canonicalize-existing "$userdir/$target")"
	    if [ "$target_real" != "$target_prefix" ]; then
	        if [ "$target_prefix" ]; then
	            rm --force --recursive "$PATH_PREFIX/$target"
	        fi
	        mkdir --parents "$PATH_PREFIX/$(dirname "$target")"
	        ln --symbolic "$target_real" "$PATH_PREFIX/$target"
	    fi
	}

	# move $PATH_PREFIX/$target to $userdir/$target (overwriting it if it exists),
	# and create symbolic link $PATH_PREFIX/$target -> $userdir/$target
	# USAGE: prefix_move_to_userdir_and_symlink $userdir $target
	prefix_move_to_userdir_and_symlink() {
	    local userdir
	    local target
	    userdir="$1"
	    target="$2"
	    if [ -e "$userdir/$target" ]; then
	        rm --force --recursive "$userdir/$target"
	    fi
	    mkdir --parents "$userdir/$(dirname "$target")"
	    cp --recursive --dereference --no-target-directory "$PATH_PREFIX/$target" "$userdir/$target"
	    rm --force --recursive "$PATH_PREFIX/$target"
	    ln --symbolic "$userdir/$target" "$PATH_PREFIX/$target"
	}

	# initialize prefix with user directories
	# USAGE: prefix_init_user_dirs $userdir $dirs
	prefix_init_user_dirs() {
	    local userdir
	    local dirs
	    userdir="$1"
	    dirs="$2"
	    # populate prefix with symlinks to specified directories
	    (
	        cd "$userdir"
	        for dir in $dirs; do
	            [ -d "$dir" ] || continue
	            prefix_symlink_to_userdir "$userdir" "$dir"
	        done
	    )
	    # move specified directories, if any, from prefix back to user directory
	    (
	        cd "$PATH_PREFIX"
	        for dir in $dirs; do
	            [ -d "$dir" ] || continue
	            if [ ! -e "$userdir/$dir" ]; then
	                prefix_move_to_userdir_and_symlink "$userdir" "$dir"
	            elif [ ! -d "$userdir/$dir" ]; then
	                display_warning \
	                    "en:Cannot overwrite '$userdir/$dir' with directory '$PATH_PREFIX/$dir'" \
	                    "fr:Impossible d'écraser '$userdir/$dir' par le répertoire '$PATH_PREFIX/$dir'"
	            fi
	        done
	    )
	}

	# initialize prefix with user files
	# USAGE: prefix_init_user_files $userdir $files
	prefix_init_user_files() {
	    local userdir
	    local files
	    userdir="$1"
	    files="$2"
	    # populate prefix with symlinks to all files in user directory
	    (
	        cd "$userdir"
	        find -L . -type f | while read -r file; do
	            prefix_symlink_to_userdir "$userdir" "$file"
	        done
	    )
	    # move specified files, if any, from prefix back to user directory
	    (
	        cd "$PATH_PREFIX"
	        for file in $files; do
	            [ -f "$file" ] || continue
	            if [ ! -e "$userdir/$file" ]; then
	                prefix_move_to_userdir_and_symlink "$userdir" "$file"
	            elif [ ! -f "$userdir/$file" ]; then
	                display_warning \
	                    "en:Cannot overwrite '$userdir/$file' with file '$PATH_PREFIX/$file'" \
	                    "fr:Impossible d'écraser '$userdir/$file' par le fichier '$PATH_PREFIX/$file'"
	            fi
	        done
	    )
	}

	# synchronize user directories with prefix
	# USAGE: prefix_sync_user_dirs $userdir $dirs
	prefix_sync_user_dirs() {
	    local userdir
	    local dirs
	    userdir="$1"
	    dirs="$2"
	    # move specified directories, if any, from prefix back to user directory
	    (
	        cd "$PATH_PREFIX"
	        for dir in $dirs; do
	            [ -d "$dir" ] || continue
	            if [ ! -h "$dir" ]; then
	                prefix_move_to_userdir_and_symlink "$userdir" "$dir"
	            fi
	        done
	    )
	    # remove user directories which are not in the prefix anymore, if any
	    (
	        cd "$userdir"
	        for dir in $dirs; do
	            [ -d "$dir" ] || continue
	            if [ ! -e "$PATH_PREFIX/$dir" ]; then
	                rm --force --recursive "$dir"
	            fi
	        done
	    )
	}

	# synchronize user files with prefix
	# USAGE: prefix_sync_user_files $userdir $files
	prefix_sync_user_files() {
	    local userdir
	    local files
	    userdir="$1"
	    files="$2"
	    # move specified files, if any, from prefix back to user directory
	    (
	        cd "$PATH_PREFIX"
	        for file in $files; do
	            [ -f "$file" ] || continue
	            if [ ! -h "$file" ]; then
	                prefix_move_to_userdir_and_symlink "$userdir" "$file"
	            fi
	        done
	    )
	    # remove user files which are not in the prefix anymore, if any
	    (
	        cd "$userdir"
	        for file in $files; do
	            [ -f "$file" ] || continue
	            if [ ! -e "$PATH_PREFIX/$file" ]; then
	                rm --force --recursive "$file"
	            fi
	        done
	    )
	}

	# create and initialize user prefix
	# USAGE: prefix_build
	prefix_build() {
	    prefix_create_dirs
	    prefix_init_game_files
	    prefix_init_user_dirs "$PATH_CONFIG" "$CONFIG_DIRS"
	    prefix_init_user_dirs "$PATH_DATA" "$DATA_DIRS"
	    prefix_init_user_files "$PATH_CONFIG" "$CONFIG_FILES"
	    prefix_init_user_files "$PATH_DATA" "$DATA_FILES"
	}

	# clean up and synchronize back user prefix
	# USAGE: prefix_cleanup
	prefix_cleanup() {
	    prefix_sync_user_dirs "$PATH_CONFIG" "$CONFIG_DIRS"
	    prefix_sync_user_dirs "$PATH_DATA" "$DATA_DIRS"
	    prefix_sync_user_files "$PATH_CONFIG" "$CONFIG_FILES"
	    prefix_sync_user_files "$PATH_DATA" "$DATA_FILES"
	}

	EOF
	sed --in-place 's/    /\t/g' "$file"
	return 0
}

# write launcher script prefix initialization
# USAGE: launcher_write_script_prefix_build $file
# CALLED BY: launcher_write_build
launcher_write_script_prefix_build() {
	local file
	file="$1"
	cat >> "$file" <<- 'EOF'
	# Build user prefix

	PATH_PREFIX="$XDG_DATA_HOME/play.it/prefixes/$PREFIX_ID"
	prefix_build

	EOF
	sed --in-place 's/    /\t/g' "$file"
	return 0
}

# write launcher script prefix cleanup
# USAGE: launcher_write_script_prefix_cleanup $file
# CALLED BY: launcher_write_build
launcher_write_script_prefix_cleanup() {
	local file
	file="$1"
	cat >> "$file" <<- 'EOF'
	# Clean up user prefix

	prefix_cleanup

	EOF
	sed --in-place 's/    /\t/g' "$file"
	return 0
}

# write launcher script pre-run actions
# USAGE: launcher_write_script_prerun $application $file
# CALLED BY: launcher_write_script_dosbox_run launcher_write_script_native_run launcher_write_script_nativenoprefix_run launcher_write_script_scummvm_run launcher_write_script_wine_run
launcher_write_script_prerun() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	local application_prerun
	application_prerun="$(get_value "${application}_PRERUN")"
	if [ "$application_prerun" ]; then
		cat >> "$file" <<- EOF
		$application_prerun

		EOF
	fi

	return 0
}

# write launcher script post-run actions
# USAGE: launcher_write_script_postrun $application $file
# CALLED BY: launcher_write_script_dosbox_run launcher_write_script_native_run launcher_write_script_nativenoprefix_run launcher_write_script_scummvm_run launcher_write_script_wine_run
launcher_write_script_postrun() {
	# parse arguments
	local application
	local file
	application="$1"
	file="$2"

	local application_postrun
	application_postrun="$(get_value "${application}_POSTRUN")"
	if [ "$application_postrun" ]; then
		cat >> "$file" <<- EOF
		$application_postrun

		EOF
	fi

	return 0
}

# write menu entry
# USAGE: launcher_write_desktop $app
# NEEDED VARS: OPTION_ARCHITECTURE PACKAGES_LIST GAME_ID GAME_NAME PATH_DESK PATH_BIN
# CALLS: error_missing_argument error_extra_arguments error_no_pkg
launcher_write_desktop() {
	# check that this has been called with exactly one argument
	if [ "$#" -eq 0 ]; then
		error_missing_argument 'launcher_write_desktop'
	elif [ "$#" -gt 1 ]; then
		error_extra_arguments 'launcher_write_desktop'
	fi

	# check that $PKG is set
	if [ -z "$PKG" ]; then
		error_no_pkg 'launcher_write_desktop'
	fi

	# skip any action if called for a package excluded for target architectures
	if [ "$OPTION_ARCHITECTURE" != 'all' ] && [ -n "${PACKAGES_LIST##*$PKG*}" ]; then
		skipping_pkg_warning 'launcher_write_desktop' "$PKG"
		return 0
	fi

	# parse argument
	local application
	application="$1"
	testvar "$application" 'APP' || liberror 'application' 'launcher_write_desktop'

	# get application-specific values
	local application_id
	local application_name
	local application_category
	local application_type
	if [ "$application" = 'APP_WINECFG' ]; then
		application_id="${GAME_ID}_winecfg"
		application_name="$GAME_NAME - WINE configuration"
		application_category='Settings'
		application_type='wine'
		application_icon='winecfg'
	else
		application_id="$(get_value "${application}_ID")"
		application_name="$(get_value "${application}_NAME")"
		application_category="$(get_value "${application}_CAT")"
		application_type="$(get_value "${application}_TYPE")"
		: "${application_id:=$GAME_ID}"
		: "${application_name:=$GAME_NAME}"
		: "${application_category:=Game}"
		application_icon="$application_id"
	fi

	# compute file name and path
	local package_path
	local target_file
	package_path="$(get_value "${PKG}_PATH")"
	[ -n "$package_path" ] || missing_pkg_error 'launcher_write_desktop' "$PKG"
	target_file="${package_path}${PATH_DESK}/${application_id}.desktop"

	# include full binary path in Exec field if using non-standard installation prefix
	local exec_field
	case "$OPTION_PREFIX" in
		('/usr'|'/usr/local')
			exec_field="$application_id"
		;;
		(*)
			exec_field="$PATH_BIN/$application_id"
		;;
	esac

	# if called in dry run mode, return before writing anything
	if [ "$DRY_RUN" -eq 1 ]; then
		return 0
	fi

	# write desktop file
	mkdir --parents "$(dirname "$target_file")"
	cat >> "$target_file" <<- EOF
	[Desktop Entry]
	Version=1.0
	Type=Application
	Name=$application_name
	Icon=$application_icon
	Exec=$exec_field
	Categories=$application_category
	EOF

	# for WINE applications, write desktop file for winecfg
	case "$application_type" in
		('wine')
			local winecfg_desktop
			winecfg_desktop="${package_path}${PATH_DESK}/${GAME_ID}_winecfg.desktop"
			if [ ! -e "$winecfg_desktop" ]; then
				launcher_write_desktop 'APP_WINECFG'
			fi
		;;
	esac

	return 0
}

# write both launcher script and menu entry for a single application
# USAGE: launcher_write $application
# NEEDED VARS: OPTION_ARCHITECTURE PACKAGES_LIST PKG
# CALLS: launcher_write_script launcher_write_desktop
# CALLED BY: launchers_write
launcher_write() {
	# skip any action if called for a package excluded for target architectures
	if [ "$OPTION_ARCHITECTURE" != 'all' ] && [ -n "${PACKAGES_LIST##*$PKG*}" ]; then
		skipping_pkg_warning 'launcher_write_script' "$PKG"
		return 0
	fi

	local application
	application="$1"
	launcher_write_script "$application"
	launcher_write_desktop "$application"
	return 0
}

# write both launcher script and menu entry for a list of applications
# USAGE: launchers_write $application[…]
# NEEDED VARS: OPTION_ARCHITECTURE PACKAGES_LIST PKG
# CALLS: launcher_write
launchers_write() {
	# skip any action if called for a package excluded for target architectures
	if [ "$OPTION_ARCHITECTURE" != 'all' ] && [ -n "${PACKAGES_LIST##*$PKG*}" ]; then
		skipping_pkg_warning 'launcher_write_script' "$PKG"
		return 0
	fi

	local application
	for application in "$@"; do
		launcher_write "$application"
	done
	return 0
}

