#!/usr/bin/env bash

function test() {
  local cmd=(dialog --clear --separate-output --backtitle Tools --checklist "Which tools you want to install?:" 0 0 0)
  local options=(
    1 "Neovim" off
    2 "Warp Terminal" off
    3 "Node" off
    4 "Google Chrome" off
    5 "Vscode" off
    6 "Postman" off
    7 "Docker" off
    8 "Dbeaver" off
    9 "Starship" off
  )

  local choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
  echo "choices: $choices"
  clear
  node=true

  if [[ $node = true ]]; then
    node_version=$(dialog --clear --stdout --backtitle "Node Version" --inputbox "Enter the node version you want to install; type lts for the latest stable release; e.g. 20, lts:" 0 0)
    echo "node_version: $node_version"
  fi
  clear
}

test
