#!/usr/bin/env bash

install_shell_zsh() {
  install_pkgs zsh
  chsh -s $(which zsh)
}

install_shell_fish() {
  if test $package_manager = apt; then
    sudo apt-add-repository ppa:fish-shell/release-3
    update_system
  fi

  install_pkgs fish
  chsh -s $(which fish)
}

install_shell() {
  cmd=(dialog --separate-output --checklist "Which shell program you want to install?:" 0 0 0)
  options=(
    1 "Zsh" off
    2 "Fish" off
  )

  local choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear

  for choice in $choices; do
    case $choice in
    1)
      install_shell_zsh
      ;;
    2)
      install_shell_fish
      ;;
    esac
  done
}
