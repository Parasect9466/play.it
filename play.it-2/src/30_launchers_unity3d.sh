# unity3D game - run the game
# USAGE: launcher_unity3d_run $application $file
# CALLED BY: launcher_write_script
launcher_unity3d_run() {
	# parse arguments
	if [ $# -lt 2 ]; then
		error_missing_argument 'launcher_unity3d_run'
	fi
	if [ $# -gt 2 ]; then
		error_extra_arguments 'launcher_unity3d_run'
	fi
	local application file
	application="$1"
	file="$2"
	if [ -z "$application" ]; then
		error_empty_string 'launcher_unity3d_run' 'application'
	fi
	if [ -z "$file" ]; then
		error_empty_string 'launcher_unity3d_run' 'file'
	fi
	if [ ! -f "$file" ]; then
		error_not_a_file "$file"
	fi
	if [ ! -w "$file" ]; then
		error_not_writable "$file"
	fi

	cat >> "$file" <<- 'EOF'
	# Run the game

	cd "$PATH_PREFIX"

	EOF
	launcher_write_script_prerun "$application" "$file"
	cat >> "$file" <<- 'EOF'
	# Use a per-session dedicated file for logs
	if [ -z "$APP_OPTIONS" ]; then
	    mkdir --parents logs
	    APP_OPTIONS="-logFile logs/$(date +%F-%R).log"
	elif [ -n "${APP_OPTIONS##* -logFile *}" ]; then
	    mkdir --parents logs
	    APP_OPTIONS="$APP_OPTIONS -logFile logs/$(date +%F-%R).log"
	fi

	# Start pulseaudio if it is available
	if command -v pulseaudio >/dev/null 2>&1; then
	    PULSEAUDIO_IS_AVAILABLE=1
	    if pulseaudio --check; then
	        KEEP_PULSEAUDIO_RUNNING=1
	    else
	        KEEP_PULSEAUDIO_RUNNING=0
	    fi
	    pulseaudio --start
	else
	    PULSEAUDIO_IS_AVAILABLE=0
	fi

	# Work around crash on launch related to alsa-lib
	# cf. https://github.com/alsa-project/alsa-lib/issues/38
	if [ $PULSEAUDIO_IS_AVAILABLE -eq 0 ]; then
	    mkdir --parents "${APP_LIBS:=libs}"
	    ln --force --symbolic /dev/null "$APP_LIBS/libasound.so.2"
	else
	    if \
	        [ -h "${APP_LIBS:=libs}/libasound.so.2" ] && \
	        [ "$(realpath "$APP_LIBS/libasound.so.2")" = '/dev/null' ]
	    then
	        rm "$APP_LIBS/libasound.so.2"
	        rmdir --ignore-fail-on-non-empty --parents "$APP_LIBS"
	    fi
	fi

	# Work around crash on launch related to libpulse
	# Some Unity3D games crash on launch if libpulse-simple.so.0 is available but pulseaudio is not running
	if [ $PULSEAUDIO_IS_AVAILABLE -eq 0 ]; then
	    mkdir --parents "${APP_LIBS:=libs}"
	    ln --force --symbolic /dev/null "$APP_LIBS/libpulse-simple.so.0"
	else
	    if \
	        [ -h "${APP_LIBS:=libs}/libpulse-simple.so.0" ] && \
	        [ "$(realpath "$APP_LIBS/libpulse-simple.so.0")" = '/dev/null' ]
	    then
	        rm "$APP_LIBS/libpulse-simple.so.0"
	        rmdir --ignore-fail-on-non-empty --parents "$APP_LIBS"
	    fi
	fi

	# Preload application-specific libraries
	if \
	    [ -n "$APP_LIBS" ] && \
	    [ -d "$APP_LIBS" ]
	then
	    if [ -n "$LD_LIBRARY_PATH" ]; then
	        LD_LIBRARY_PATH="$APP_LIBS:$LD_LIBRARY_PATH"
	    else
	        LD_LIBRARY_PATH="$APP_LIBS"
	    fi
	    export LD_LIBRARY_PATH
	fi

	# Work around Unity3D poor support for non-US locales
	export LANG=C

	set +o errexit
	# shellcheck disable=SC2086
	"./$APP_EXE" $APP_OPTIONS "$@"
	set -o errexit

	# Stop pulseaudio if it has specifically been started for the game
	if \
	    [ $PULSEAUDIO_IS_AVAILABLE -eq 1 ] && \
	    [ $KEEP_PULSEAUDIO_RUNNING -eq 0 ]
	then
	    pulseaudio --kill
	fi

	EOF
	launcher_write_script_postrun "$application" "$file"
	sed --in-place 's/    /\t/g' "$file"
	return 0
}

