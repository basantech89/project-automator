#!/usr/bin/env bash

select_shell() {
  local options=(
    1 "Bash" off
    2 "Zsh" off
    3 "Fish" on
  )

  local choice=$(dialog --clear --stdout --backtitle "Shell" --radiolist "Which primary shell program you want to use?:" 0 0 0 "${options[@]}")

  local current_shell=$(sh -c 'ps -p $$ -o ppid=' | xargs ps -o comm= -p)
  clear

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
    1 "Neovim" on
    2 "Warp Terminal" on
    3 "Starship" on
    4 "Node" on
    5 "Google Chrome" on
    6 "Vscode" on
    7 "Postman" on
    8 "Docker" on
    9 "Dbeaver" on
    10 "AWS CLI" on
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
      starship=true
      ;;
    4)
      node=true
      ;;
    5)
      chrome=true
      ;;
    6)
      vscode=true
      ;;
    7)
      postman=true
      ;;
    8)
      docker=true
      ;;
    9)
      dbeaver=true
      ;;
    10)
      aws_cli=true
      ;;
    esac
  done

  if [[ $node = true ]]; then
    if ! is_pkg_installed nvm || ! is_pkg_installed node; then
      node_version=$(dialog --clear --stdout --backtitle "Node Version" --inputbox "Enter the node version you want to install; type lts for the latest stable release; e.g. 20, lts:" 0 0)
    fi
  fi

  clear
}

prompt_user() {
  select_shell
  select_tools
}
