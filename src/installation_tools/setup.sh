#!/usr/bin/env bash

. ./src/variables.sh
. ./src/utils/common.sh
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
    echo "echoing ${already_installed_pkgs[*]}"
    export already_installed_pkgs
    for choice in $choices; do
        case $choice in
        1)
            print_info "${INFO}" "Installing I3 Window Manager"
            # install_i3
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

prepare_tools_installation() {
    if [ "${EUID}" -eq 0 ]; then
        print_info "${INFO}" "You are ROOT. Installing Tools as user ROOT is not supported.\nWhat would you like to do ?"
        options=("Create a new user" "Switch to a user" "Exit")
        select item in "${options[@]}"; do
            case "${REPLY}" in
            1)
                set_variable new_username
                set_variable new_user_password
                [ -f /usr/bin/zsh ] && USER_SHELL="/usr/bin/zsh" || USER_SHELL="/usr/bin/bash"
                useradd -mg users -G wheel,storage,power -s "${USER_SHELL}" "${new_username}"
                echo "${new_username}:${new_user_password}" | chpasswd
                sed -i "/# %wheel ALL=(ALL) ALL/ s/# //" /etc/sudoers
                sudo -u "${new_username}" ./src/installation_tools/install_tools.sh
                ;;
            2)
                set_variable new_username
                sudo -u "${new_username}" ./src/installation_tools/install_tools.sh
                ;;
            *)
                print_info "${ERROR}" "ROOT user isn't supported. Exiting."
                exit "${ROOT_USER_NOT_SUPPORTED}"
                ;;
            esac
            break
        done
    else
        ./src/installation_tools/install_tools.sh
    fi
}
