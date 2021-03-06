#!/usr/bin/env bash

. ~/project_automator/src/assets/colors.sh
. ~/project_automator/src/variables.sh

prompt_variable() {
	print_info "${PROMPT}" "Please type ${1} ${NC}"
	read -r prompt_result
	print_info "${INFO}" "You provided ${prompt_result} as the input."
	print_info "${PROMPT}" "Press y|Y if this is correct. Press any other key to try again"
}

set_variable() {
	prompt_variable "${1}"
	pass="${2}"
	while read -r response; do
		case "$response" in
		["Yy"])
			eval export "${pass}=${prompt_result}"
			break
			;;
		*) prompt_variable "${1}" ;;
		esac
	done
}

check_if_array() {
	local regex="^declare -[aA]"
	if [[ "$(declare -p "${1}")" =~ ${regex} ]]; then
		return 0
	else
		return 1
	fi
}

is_pkg_installed() {
	if pacman -Qi "${1}" &>/dev/null; then
		print_info "${INFO}" "Package ${1} is already installed, not installing again"
		return "${RESOLVED}"
	else
		if which "${1}" &>/dev/null; then
			print_info "${INFO}" "Package ${1} is already installed, not installing again"
			return "${RESOLVED}"
		else
			print_info "${INFO}" "Installing Package ${1}"
			return "${PKG_NOT_EXISTS}"
		fi
	fi
}

install_pkg() {
	if is_pkg_installed "${2}"; then
		already_installed_pkgs+=("${2}")
	else
		if [ "${1}" = 'aur' ]; then
			yay -S "${2}" --answerdiff N --answerclean A --answeredit N --answerupgrade A --cleanafter --norebuild --noredownload --noconfirm
		elif [ "${1}" = 'snap' ]; then
			sudo snap install "${2}"
		else
			sudo pacman -S "${2}" --needed --noconfirm --overwrite '*'
		fi
		[ $? -eq 0 ] && successful_pkgs+=("${2}") || failed_pkgs+=("${2}")
	fi
}

install_pkgs() {
	PKG_MANAGER="${1}"
	shift
	for pkg in "${@}"; do
		install_pkg "${PKG_MANAGER}" "${pkg}"
	done
}

update_shell() {
	if [ -f /bin/zsh ]; then
		user_shell="/bin/zsh"
	elif [ -f /usr/bin/zsh ]; then
		user_shell="/usr/bin/zsh"
	elif [ -f /bin/bash ]; then
		user_shell="/bin/bash"
	else
		user_shell="/usr/bin/bash"
	fi
	export user_shell
}

update_system() {
	sudo pacman -Sy --noconfirm
}

print_info() {
	echo -e "${1}${2}${NC}"
}

divider() {
	echo -e "${SEPARATOR} ===================  ${1}  =================== ${NC}"
}

# EXAMPLES
#print_info "${TITLE}" "This is a Title"
#print_info "${SUBTITLE}" "This is a Sub Title"
#print_info "${ERROR}" "This is an Error"
#print_info "${SUCCESS}" "This is a success"
#print_info "${BGSUCCESS}" "This is a bg success"
#print_info "${PRIMARY}" "This is a PRIMARY"
#print_info "${BGWARNING}" "This is a bg warning"
#print_info "${WARNING}" "This is a warning"
#print_info "${SECONDARY}" "This is a SECONDARY"
#print_info "${BGINFO}" "This is a bg INFO"
#print_info "${INFO}" "This is a INFO"
#divider "Start Installation"
