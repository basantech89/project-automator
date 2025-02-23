#!/usr/bin/env bash

install_neovim() {
  if test $package_manager = apt; then
    sudo add-apt-repository ppa:neovim-ppa/stable
    sudo apt-get update

    install_pkgs python-dev python-pip python3-dev python3-pip
  fi

  install_pkgs neovim
}

install_warp_terminal() {
  if [ "$package_manager" = 'pacman' ]; then
    sudo tee -a /etc/pacman.conf >/dev/null <<EOF
[warpdotdev]
Server = https://releases.warp.dev/linux/pacman/\$repo/\$arch
EOF
    install_pkgs warp-terminal
  elif [ "$package_manager" = 'apt' ]; then
    wget -qO- https://releases.warp.dev/linux/keys/warp.asc | gpg --dearmor >warpdotdev.gpg
    sudo install -D -o root -g root -m 644 warpdotdev.gpg /etc/apt/keyrings/warpdotdev.gpg
    sudo sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" > /etc/apt/sources.list.d/warpdotdev.list'
    rm warpdotdev.gpg

    update_system
    install_pkgs warp-terminal
  elif [ "$package_manager" = 'brew' ]; then
    install_pkgs --cask warp
  fi
}

install_node() {
  if [ -f ~/.config/fish/config.fish ]; then

  fi

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

  if [ -f ~/.bashrc ]; then
    cat >>~/.bashrc <<EOF
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
EOF
  fi

  if [ -f ~/.zshrc ]; then
    cat >>~/.zshrc <<EOF
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
EOF
  fi
}
