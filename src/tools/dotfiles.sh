#!/usr/bin/env bash

copy_dotfiles() {
  install_pkgs stow

  mark_start "Copying DOTFILES" -t$SUBTITLE

  local DOTFILES_REPO="https://github.com/basantech89/dotfiles.git"

  DOTFILES_DIR="$HOME/dotfiles"
  local MAKEFILE="$DOTFILES_DIR/makefile"

  if [ -d "$DOTFILES_DIR" ]; then
    log "${INFO}" "Dotfiles directory already exists."
  else
    log "${INFO}" "Cloning dotfiles repository into ${DOTFILES_DIR}..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi

  mark_end "Copying DOTFILES" -t$SUBTITLE
}

install_dot() {
  if [ -n "$2" ]; then
    rm -rf "$2"
  fi

  pushd $DOTFILES_DIR
  make "$1"
  popd
}
