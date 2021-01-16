#!/usr/bin/env bash

install_devtools() {
    # nvm and node
    wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
    cat >>~/.zshrc <<EOF
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
EOF
    # shellcheck source=${HOME}/.zshrc
    source "${HOME}/.zshrc"
    nvm install node
    nvm use node
    # yarn
    install_pkgs pacman yarn
    PATH="$PATH:$(yarn global bin)"
    export PATH
}
