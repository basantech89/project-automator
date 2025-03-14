#!/usr/bin/env bash

install_prerequisites() {
  install_pkgs git sudo curl wget gpg jq xclip vim cowsay lolcat

  if [ "$package_manager" = 'pacman' ]; then
    install_pkgs bash-completion

    is_pkg_installed paru && already_installed_pkgs+=('paru') || {
      mark_start "Install Prerequisites"

      cd $HOME
      echo "$SUDO_PASSWORD" | sudo -S pacman -S --needed --noconfirm base-devel
      git clone https://aur.archlinux.org/paru.git
      cd paru
      makepkg -si

      mark_end "Install Prerequisites"
      cd $HOME
    }
  elif [ "$package_manager" = 'apt-get' ]; then
    mark_start "Install Prerequisites"

    install_pkgs software-properties-common apt-transport-https ca-certificates bash-completion

    mark_end "Install Prerequisites" -t$SUBTITLE
  elif [ "$package_manager" = 'brew' ]; then
    is_pkg_installed brew && already_installed_pkgs+=('brew') || {
      mark_start "Install Prerequisites"

      cd $HOME
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      install_pkgs bash-completion@2

      mark_end "Install Prerequisites" -t$SUBTITLE
    }
  fi
}
