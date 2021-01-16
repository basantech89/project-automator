#!/usr/bin/env bash

. ./src/utils/common.sh
. ./src/installation_system/setup.sh
. ./src/installation_i3/setup.sh
. ./src/installation_drivers/setup.sh
. ./src/installation_ricing/setup.sh
. ./src/installation_devtools/setup.sh

export successful_pkgs=()
export failed_pkgs=()
export already_installed_pkgs=()

main_menu() {
	cmd=(dialog --separate-output --checklist "Select options:" 22 76 16)
	options=(1 "Install Arch Linux" off # any option can be set to default to "on"
		2 "Install I3 Window Manager" off
		3 "Install Drivers" off
		4 "Install Ricing Environment" off
		5 "Install Development Tools" off)
	choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
	clear
	for choice in $choices; do
		case $choice in
		1)
			prepare_system_installation
			;;
		2)
			install_i3
			;;
		3)
			install_drivers
			;;
		4)
			install_ricing
			;;
		5)
			install_devtools
			;;
		esac
	done
}

main_menu
print_info "${SUCCESS}" "Successfully Installed Packages ${successful_pkgs[*]}"
print_info "${ERROR}" "Failed Packages ${failed_pkgs[*]}"
print_info "${WARNING}" "Already Installed Packages ${already_installed_pkgs[*]}"
