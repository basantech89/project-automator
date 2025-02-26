#!/usr/bin/env bash

install_tools() {
  [[ $neovim = true ]] && install_neovim
  [[ $warp = true ]] && install_warp_terminal
  [[ $node = true ]] && install_node
  [[ $starship = true ]] && install_starship
}

install() {
  mark_start "Install" $TITLE

  install_shell
  install_tools

  mark_end "Install" $TITLE
}
