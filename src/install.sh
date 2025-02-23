#!/usr/bin/env bash

pkgs_to_install=()

install_dotfiles() {
  install_pkgs stow

  cd $HOME
  mark_start "Dotfiles Installation" $TITLE
  break_line

  DOTFILES_REPO="git@github.com:basantech89/dotfiles.git"
  DOTFILES_DIR="$HOME/dotfiles"

  if [ -d "$DOTFILES_DIR" ]; then
    log "${INFO}" "Dotfiles directory already exists."
    break_line
  else
    log "${INFO}" "Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    break_line
  fi

  log "${INFO}" "Installing dotfiles..."
  cd $DOTFILES_DIR
  make
  break_line

  mark_end "Dotfiles Installation" $TITLE
}

install() {
  cmd=(dialog --separate-output --checklist "Which tools you want to install?:" 0 0 0)
  options=(
    1 "Neovim" off
    2 "Shell" off
    3 "Terminal" off
    4 "Node" off
    5 "Google Chrome" off
    6 "Vscode" off
    7 "Postman" off
    8 "Docker" off
    9 "Dbeaver" off
  )

  local choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  clear

  for choice in $choices; do
    case $choice in
    1)
      install_neovim
      ;;
    2)
      install_warp_terminal
      ;;
    3)
      install_warp_terminal
      ;;
    4)
      install_node
      ;;
    5)
      install_chrome
      ;;
    6)
      install_vscode
      ;;
    7)
      install_postman
      ;;
    8)
      install_docker
      ;;
    9)
      install_dbeaver
      ;;
    esac
  done
}
