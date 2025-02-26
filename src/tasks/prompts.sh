#!/usr/bin/env bash

select_shell() {
  local options=(
    1 "Bash" off
    2 "Zsh" off
    3 "Fish" on
  )

  local choice=$(dialog --clear --stdout --backtitle "Shell" --radiolist "Which primary shell program you want to use?:" 0 0 0 "${options[@]}")

  local current_shell=$(sh -c 'ps -p $$ -o ppid=' | xargs ps -o comm= -p)
  # clear

  case $choice in
  1)
    shell=bash
    ;;
  2)
    shell=zsh
    ;;
  3)
    shell=fish
    ;;
  esac
}

select_tools() {
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

  for choice in $choices; do
    case $choice in
    1)
      neovim=true
      ;;
    2)
      warp=true
      ;;
    3)
      node=true
      ;;
    4)
      chrome=true
      ;;
    5)
      vscode=true
      ;;
    6)
      postman=true
      ;;
    7)
      docker=true
      ;;
    8)
      dbeaver=true
      ;;
    9)
      starship=true
      ;;
    esac
  done

  if [[ $node = true ]]; then
    node_version=$(dialog --clear --stdout --backtitle "Node Version" --inputbox "Enter the node version you want to install; type lts for the latest stable release; e.g. 20, lts:" 0 0)
  fi

  # clear
}

prompt_user() {
  select_shell
  select_tools
}
