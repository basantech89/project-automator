#!/usr/bin/env bash

install_neovim() {
  if test $package_manager = apt-get; then
    add_apt_repo ppa:neovim-ppa/stable
    update_system quiet

    install_pkgs python2-dev python-pip python3-dev python3-pip
  fi

  install_pkgs neovim
}

install_warp_terminal() {
  if ! is_pkg_installed warp-terminal quite; then
    if [ "$package_manager" = 'pacman' ]; then
      echo "$SUDO_PASSWORD" | sudo tee -a /etc/pacman.conf >/dev/null <<EOF
[warpdotdev]
Server = https://releases.warp.dev/linux/pacman/\$repo/\$arch
EOF
      install_pkgs warp-terminal
    elif [ "$package_manager" = 'apt-get' ]; then
      wget -qO- https://releases.warp.dev/linux/keys/warp.asc | gpg --dearmor >warpdotdev.gpg
      echo "$SUDO_PASSWORD" | sudo install -D -o root -g root -m 644 warpdotdev.gpg /etc/apt/keyrings/warpdotdev.gpg
      echo "$SUDO_PASSWORD" | sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" > /etc/apt/sources.list.d/warpdotdev.list'
      rm warpdotdev.gpg

      update_system quiet
      install_pkgs warp-terminal
    elif [ "$package_manager" = 'brew' ]; then
      install_pkgs --cask warp
    fi
  fi
}

install_node() {
  if ! is_pkg_installed node; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

    if [ $shell = bash ]; then
      cat >>~/.bashrc <<EOF
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
EOF
    fi

    if [ $shell = zsh ]; then
      cat >>~/.zshrc <<EOF
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
EOF
    fi

    if [ $shell = fish ]; then
      fish -c "fisher install jorgebucaran/nvm.fish"
    fi

    source_shell_config

    $shell -c "
      nvm install "${node_version}"
      nvm alias default "${node_version}"
      nvm use default
      npm i -g pnpm yarn nx
    "
  fi
}
