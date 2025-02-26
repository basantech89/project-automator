#!/usr/bin/env bash

install_prerequisites() {
  install_pkgs git sudo curl wget gpg

  if [ "$package_manager" = 'pacman' ]; then
    is_pkg_installed paru && already_installed_pkgs+=('paru') || {
      mark_start "Install Prerequisites"

      cd $HOME
      sudo pacman -S --needed --noconfirm base-devel
      git clone https://aur.archlinux.org/paru.git
      cd paru
      makepkg -si

      mark_end "Install Prerequisites"
      cd $HOME
    }
  elif [ "$package_manager" = 'apt-get' ]; then
    mark_start "Install Prerequisites"

    sudo "$package_manager" update
    install_pkgs software-properties-common

    mark_end "Install Prerequisites"
  elif [ "$package_manager" = 'brew' ]; then
    is_pkg_installed brew && already_installed_pkgs+=('brew') || {
      mark_start "Install Prerequisites"

      cd $HOME
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

      mark_end "Install Prerequisites"
    }
  fi
}
