#!/usr/bin/env bash

. "${HOME}"/project_automator/src/variables.sh
. "${HOME}"/project_automator/src/utils/common.sh

prepare_tools_installation() {
    if [ "${EUID}" -eq 0 ]; then
        print_info "${INFO}" "You are ROOT. Installing Tools as user ROOT is not supported.\nWhat would you like to do ?"
        options=("Create a new user" "Switch to a user" "Exit")
        select item in "${options[@]}"; do
            case "${REPLY}" in
            1)
                set_variable new_username
                set_variable new_user_password
                update_shell
                # [ -f /usr/bin/zsh ] && USER_SHELL="/usr/bin/zsh" || USER_SHELL="/usr/bin/bash"
                useradd -mg users -G wheel,storage,power -s "${user_shell}" "${new_username}"
                echo "${new_username}:${new_user_password}" | chpasswd
                sed -i "/# %wheel ALL=(ALL) ALL/ s/# //" /etc/sudoers
                sudo -u "${new_username}" "${HOME}"/project_automator/src/installation_tools/install_tools.sh
                ;;
            2)
                set_variable username
                sudo -u "${username}" "${HOME}"/project_automator/src/installation_tools/install_tools.sh
                ;;
            *)
                print_info "${ERROR}" "ROOT user isn't supported. Exiting."
                exit "${ROOT_USER_NOT_SUPPORTED}"
                ;;
            esac
            break
        done
    else
        "${HOME}"/project_automator/src/installation_tools/install_tools.sh
    fi
}
