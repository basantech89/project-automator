#!/usr/bin/env bash

install_node() {
    print_info "${SUCCESS}" "Installing Node through NVM"
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
    cat >>~/.zshrc <<EOF
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
EOF
    # shellcheck source=${HOME}/.zshrc
    source "${HOME}/.zshrc"
    nvm install node
    nvm use node
}

install_yarn() {
    print_info "${SUCCESS}" "Installing Yarn"
    install_pkgs pacman yarn
    PATH="$PATH:$(yarn global bin)"
    export PATH
}

install_devtools() {
    divider "START: Dev Tools Installation"
    install_node
    install_yarn
    divider "END: Dev Tools Installation"
} > >(tee -i installation_devtools.log) 2> >(tee -i installation_error_devtools.log >&2)
