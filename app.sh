#!/usr/bin/env bash

./src/variables.sh
. ./src/utils/common.sh
. ./src/utils/helper.sh
. ./src/installation_system/setup.sh
. ./src/installation_tools/setup.sh

show_summary() {
	PKGS_FILE="/home/${new_username}/packages.log"
	if [ -f "${PKGS_FILE}" ]; then
		successfull=$(grep -i "successfully installed packages:" "${PKGS_FILE}" | sed 's/^.*Packages: //')
		failed=$(grep -i "failed installed packages:" "${PKGS_FILE}" | sed 's/^.*Packages: //')
		already_installed=$(grep -i "already installed packages:" "${PKGS_FILE}" | sed 's/^.*Packages: //')
		successful_pkgs+=("${successfull[*]}")
		failed_pkgs+=("${failed[*]}")
		already_installed_pkgs+=("${already_installed[*]}")
		rm "${PKGS_FILE}"
	fi

	print_info "${SUCCESS}" "Successfully Installed Packages: ${successful_pkgs[*]}"
	print_info "${ERROR}" "Failed Packages: ${failed_pkgs[*]}"
	print_info "${WARNING}" "Already Installed Packages: ${already_installed_pkgs[*]}"
	{
		print_info "${SUCCESS}" "Successfully Installed Packages: ${successful_pkgs[*]}"
		print_info "${ERROR}" "Failed Packages: ${failed_pkgs[*]}"
		print_info "${WARNING}" "Already Installed Packages: ${already_installed_pkgs[*]}"
	} >>~/packages.log
}

main_menu() {
	install_pkgs pacman dialog sudo
	cmd=(dialog --separate-output --checklist "Select options:" 22 76 16)
	options=(1 "Install Arch Linux" off # any option can be set to default to "on"
		2 "Install Tools" off)
	local choices
	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	clear
	for choice in $choices; do
		case $choice in
		1)
			prepare_system_installation
			;;
		2)
			prepare_tools_installation
			;;
		esac
	done
} > >(tee -i main.log) 2> >(tee -i main_error.log >&2)

main_menu
show_summary
