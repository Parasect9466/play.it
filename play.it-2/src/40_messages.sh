# display an error when a function is called without an argument, but is expecting some
# USAGE: error_missing_argument $function
error_missing_argument() {
	local message function
	function="$1"
	case "${LANG%_*}" in
		('fr')
			message='La fonction "%s" ne peut pas être appelée sans argument.\n'
		;;
		('en'|*)
			message='"%s" function can not be called without an argument.\n'
		;;
	esac
	print_error
	printf "$message" "$function"
	return 1
}

# display an error when a function is called with multiple arguments, but is expecting no more than one
# USAGE: error_extra_arguments $function
error_extra_arguments() {
	local message function
	function="$1"
	case "${LANG%_*}" in
		('fr')
			message='La fonction "%s" ne peut pas être appelée avec plus dʼun argument.\n'
		;;
		('en'|*)
			message='"%s" function can not be called with mor than one single argument.\n'
		;;
	esac
	print_error
	printf "$message" "$function"
	return 1
}

# display an error when a function requiring $PKG to be set is called while it is unset
# USAGE: error_no_pkg $function
error_no_pkg() {
	local message function
	function="$1"
	case "${LANG%_*}" in
		('fr')
			message='La fonction "%s" ne peut pas être appelée lorsque $PKG nʼa pas de valeur définie.\n'
		;;
		('en'|*)
			message='"%s" function can not be called when $PKG is not set.\n'
		;;
	esac
	print_error
	printf "$message" "$function"
	exit 1
}

# display an error when a file is expected and something else has been given
# USAGE: error_not_a_file $param
error_not_a_file() {
	local message param
	param="$1"
	case "${LANG%_*}" in
		('fr')
			message='"%s" nʼest pas un fichier valide.\n'
		;;
		('en'|*)
			message='"%s" is not a valid file.\n'
		;;
	esac
	print_error
	printf "$message" "$param"
	return 1
}

# display an error when an unknown application type is used
# USAGE: error_unknown_application_type $app_type
error_unknown_application_type() {
	local message application_type
	application_type="$1"
	case "${LANG%_*}" in
		('fr')
			message='Le type dʼapplication "%s" est inconnu.\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='"%s" application type is unknown.\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	print_error
	printf "$message" "$application_type" "$PLAYIT_GAMES_BUG_TRACKER_URL"
	return 1
}

# display an error when the available tar implementation is not supported
# USAGE: error_unknown_tar_implementation
error_unknown_tar_implementation() {
	local message
	case "${LANG%_*}" in
		('fr')
			message='La version de tar présente sur ce système nʼest pas reconnue.\n'
			message="$message"'./play.it ne peut utiliser que GNU tar ou bsdtar.\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='The tar implementation on this system wasnʼt recognized.\n'
			message="$message"'./play.it can only use GNU tar or bsdtar.\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	print_error
	printf "$message" "$PLAYIT_BUG_TRACKER_URL"
	return 1
}

# display a message when a required dependency is missing
# USAGE: error_dependency_not_found $command_name
error_dependency_not_found() {
	local message command_name provider
	command_name="$1"
	provider="$(dependency_provided_by "$command_name")"
	case "${LANG%_*}" in
		('fr')
			message='%s est introuvable. Installez %s avant de lancer ce script.\n'
		;;
		('en'|*)
			message='%s not found. Install %s before running this script.\n'
		;;
	esac
	print_error
	printf "$message" "$command_name" "$provider"
	return 1
}

# display an error when trying to extract an archive but no extractor is present
# USAGE: error_archive_no_extractor_found $archive_type
error_archive_no_extractor_found() {
	local message archive_type
	archive_type="$1"
	case "${LANG%_*}" in
		('fr')
			message='Ce script a essayé dʼextraire le contenu dʼune archive de type "%s", mais aucun outil approprié nʼa été trouvé.\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='This script tried to extract the contents of a "%s" archive, but not appropriate tool could be found.\n'
			message="$message"'Please report this issue in our bug tracker: %s\n'
		;;
	esac
	print_error
	printf "$message" "$archive_type" "$PLAYIT_GAMES_BUG_TRACKER_URL"
	return 1
}

# Display an error when trying to write a launcher for a missing binary
# USAGE: error_launcher_missing_binary $binary
# CALLS: print_error
error_launcher_missing_binary() {
	local binary message
	binary="$1"
	case "${LANG%_*}" in
		('fr')
			message='Le fichier suivant est introuvable, mais la création dʼun lanceur pour celui-ci a été demandée : %s\n'
			message="$message"'Merci de signaler cette erreur sur notre outil de gestion de bugs : %s\n'
		;;
		('en'|*)
			message='The following file can not be found, but a launcher targeting it should have been created: %s\n'
			message="$message"'Please report this issue on our bug tracker: %s\n'
		;;
	esac
	print_error
	printf "$message" "$binary" "$PLAYIT_GAMES_BUG_TRACKER_URL"
	return 1
}

