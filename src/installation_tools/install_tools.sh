#!/usr/bin/env bash

. ./src/variables.sh
. ./src/installation_i3/setup.sh
. ./src/installation_drivers/setup.sh
. ./src/installation_ricing/setup.sh
. ./src/installation_devtools/setup.sh

install_basic_tools() {
    install_pkgs pacman wget vim wpa_supplicant git
    if ! command -v yay &>/dev/null; then
        print_info "${INFO}" "Installing YAY Aur Helper"
        cd ~ || exit
        is_pkg_installed fakeroot || install_pkgs pacman base-devel
        git clone https://aur.archlinux.org/yay.git
        cd yay || exit
        makepkg -si --noconfirm
        cd ~ || exit
        successful_pkgs+=('yay')
    else
        already_installed_pkgs+=('yay')
        print_info "${INFO}" "YAY Aur Helper is already installed, not installing again"
    fi
}

tools_menu() {
    cmd=(dialog --separate-output --checklist "Select options:" 22 76 16)
    options=(1 "Install I3 Window Manager" off # any option can be set to default to "on"
        2 "Install Drivers" off
        3 "Install Ricing Environment" off
        4 "Install Development Tools" off)
    local choices
    choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
    clear
    install_basic_tools
    for choice in $choices; do
        case $choice in
        1)
            print_info "${INFO}" "Installing I3 Window Manager"
            install_i3
            ;;
        2)
            print_info "${INFO}" "Installing System Drivers"
            install_drivers
            ;;
        3)
            print_info "${INFO}" "Installing Ricing Environment"
            install_ricing
            ;;
        4)
            print_info "${INFO}" "Installing Dev Tools"
            install_devtools
            ;;
        esac
    done
}

tools_menu

{
    print_info "${SUCCESS}" "Successfully Installed Packages: ${successful_pkgs[*]}"
    print_info "${ERROR}" "Failed Packages: ${failed_pkgs[*]}"
    print_info "${WARNING}" "Already Installed Packages: ${already_installed_pkgs[*]}"
} >>~/packages.log
