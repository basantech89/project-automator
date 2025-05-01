#!/usr/bin/env bash

install_tools() {
  [[ $neovim = true ]] && install_neovim
  [[ $warp = true ]] && install_warp_terminal
  [[ $node = true ]] && install_node

  if test $shell != "zsh"; then
    [[ $starship = true ]] && install_starship
  fi

  [[ $chrome = true ]] && install_google_chrome
  [[ $vscode = true ]] && install_vscode
  [[ $dbeaver = true ]] && install_dbeaver
  [[ $postman = true ]] && install_postman
  [[ $docker = true ]] && install_docker
  [[ $aws_cli = true ]] && install_aws_cli
  [[ $brave_browser = true ]] && install_brave_browser
  [[ $ms_teams = true ]] && install_ms_teams
  [[ $notion = true ]] && install_notion
  [[ $slack = true ]] && install_slack
}

install() {
  mark_start "Install" -t$SUBTITLE

  install_shell
  install_fonts
  install_tools

  mark_end "Install" -t$SUBTITLE
}
