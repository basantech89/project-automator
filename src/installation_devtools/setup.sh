#!/usr/bin/env bash

install_node() {
    print_info "${SUCCESS}" "Installing Node through NVM"
    # wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | zsh
    git clone https://github.com/nvm-sh/nvm.git .nvm
    cd ~/.nvm
    . ./nvm.sh
    cat >>~/.zshrc <<EOF
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
EOF
    nvm install node
    nvm use node
    install_pkgs pacman npm
    successful_pkgs+=('nvm' 'nsudoode' 'npm')
}

install_yarn() {
    print_info "${SUCCESS}" "Installing Yarn"
    install_pkgs pacman yarn
    PATH="$PATH:$(yarn global bin)"
    export PATH
}

install_docker() {
    sudo tee /etc/modules-load.d/loop.conf <<<"loop" # enable the loop module
    modprobe loop
    install_pkgs pacman docker
    sudo systemctl start docker.service
    sudo systemctl enable docker.service
    sudo groupadd docker
    sudo usermod -aG docker "${USER}"
}

install_devtools() {
    divider "START: Dev Tools Installation"
    install_node
    install_yarn
    install_pkgs pacman peek gifski
    install_pkgs aur google-chrome postman-bin visual-studio-code-bin webstorm
    install_docker
    sudo systemctl start snapd
    install_pkgs snap mailspring
    divider "END: Dev Tools Installation"
} > >(tee -i ~/project_automator/installation_devtools.log) 2> >(tee -i ~/project_automator/installation_error_devtools.log >&2)
sudo
