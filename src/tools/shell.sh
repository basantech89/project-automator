#!/usr/bin/env bash

install_shell_zsh() {
  install_pkgs zsh
  cd "$DOTFILES_DIR"
  make zsh
  cd ~
}

install_shell_fish() {
  if test $package_manager = apt-get; then
    add_apt_repo ppa:fish-shell/release-3
  fi

  install_pkgs fish
  fish -c "test $(fisher -v) || curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"

  cd "$DOTFILES_DIR"
  make fish
  cd ~
}

install_shell() {
  local current_shell=$(sh -c 'ps -p $$ -o ppid=' | xargs ps -o comm= -p)

  case $shell in
  bash)
    test $current_shell = "bash" || chsh -s $(which bash)
    ;;
  zsh)
    test $current_shell = "zsh" || chsh -s $(which zsh)
    install_shell_zsh
    ;;
  fish)
    test $current_shell = "fish" || chsh -s $(which fish)
    install_shell_fish
    ;;
  esac
}
