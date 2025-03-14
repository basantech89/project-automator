#!/usr/bin/env bash

log() {
  echo -e "${@}${NC}"
}

mark_start() {
  local mark_type="${PROMPT}"

  local options=$(getopt -o t:: --long "mark_type::" -- "${@}")
  eval set -- "${options}"

  while [ -n "$1" ]; do
    case "$1" in
    -t | --mark_type)
      mark_type="${2}"
      shift 2
      ;;
    *)
      shift
      break
      ;;
    esac
  done

  log "${mark_type}" "------------------- START: ${@} -------------------"
}

mark_end() {
  local mark_type="${PROMPT}"

  local options=$(getopt -o t:: --long "mark_type::" -- "${@}")
  eval set -- "${options}"

  while [ -n "$1" ]; do
    case "$1" in
    -t | --mark_type)
      mark_type="${2}"
      shift 2
      ;;
    *)
      shift
      break
      ;;
    esac
  done

  log "${mark_type}" "------------------- END: ${@} -------------------"
}

break_line() {
  echo -ne "\n"
}

prompt_variable() {
  log "${PROMPT}" "Please type ${1} ${NC}"
  read -r prompt_result
  log "${INFO}" "You provided ${prompt_result} as the input."
  log "${PROMPT}" "Press y|Y if this is correct. Press any other key to try again"
}

set_variable() {
  prompt_variable "${1}"
  local pass="${2}"
  while read -r response; do
    case "$response" in
    ["Yy"])
      eval export "${pass}=${prompt_result}"
      break
      ;;
    *) prompt_variable "${1}" ;;
    esac
  done
}

install_nerd_fonts() {
  local fonts_dir="${HOME}/.local/share/fonts"
  local fonts_to_install=()

  local arg_list=("$@")
  for i in "${!arg_list[@]}"; do
    local this_element="${arg_list[i]}"
    local next_element="${arg_list[i + 1]}"
    local next_next_element="${arg_list[i + 2]}"

    if [[ $this_element == "-s" ]]; then
      local font_to_look="${next_element}"
      if fc-list | grep -i "${font_to_look}" >/dev/null 2>&1; then
        log "${INFO}" "Font ${font} is already installed."
        shift 3
      else
        fonts_to_install+=("${next_next_element}")
        shift 2
      fi
    fi
  done

  local version=$(curl -s 'api.github.com/repos/ryanoasis/nerd-fonts/releases/latest' | jq -r '.name')
  if [ -z "$version" ] || [ "$version" = "null" ]; then
    version="v3.3.0"
  fi

  if [[ ${#fonts_to_install[@]} -eq 0 ]]; then
    return
  fi

  if [[ ! -d "$fonts_dir" ]]; then
    mkdir -p "$fonts_dir"
  fi

  mark_start "Installing Fonts ${fonts_to_install[@]}" -t$FONT

  for font in "${fonts_to_install[@]}"; do
    local zip_file="${font}.zip"
    local download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${version}/${zip_file}"
    wget -O "/tmp/$zip_file" "$download_url" >/dev/null 2>&1

    if [ -f "/tmp/$zip_file" ]; then
      log "${INFO}" "Downloaded ${zip_file} successfully."
    else
      log "${ERROR}" "Failed to download ${zip_file}."
      return "${FONT_NOT_INSTALLEd}"
    fi

    unzip "/tmp/$zip_file" -d "/tmp/${font}"
    mv /tmp/${font}/*.ttf "$fonts_dir"
    rm -rf "/tmp/${font}"
    rm "/tmp/$zip_file"
  done

  find "$fonts_dir" -name 'Windows Compatible' -delete

  fc-cache -fv

  mark_end "Installing Fonts ${fonts_to_install[@]}" -t$FONT
}

validate_version() {
  if [ $package_manager = "apt-get" ]; then
    if (
      echo minVersion: "$1"
      apt-cache policy "$2" | grep -i candidate | awk '{$1=$1};1' | cut -d - -f 1
    ) | sort -Vk2 | tail -1 | grep -iq candidate; then
      return "${RESOLVED}"
    else
      log "${WARN}" "Minimum version requirement $1 failed for candidate $2."
      return "${VALIDATE_VERSION_FAILED}"
    fi
  elif [ $package_manager = "pacman" ]; then
    if (
      echo "$1"
      pacman -Ss "$2" | head -1 | cut -d ' ' -f 2 | cut -d - -f 1
    ) | sort -V | head -1 | grep -iq $1; then
      return "${RESOLVED}"
    else
      log "${WARN}" "Minimum version requirement $1 failed for candidate $2."
      return "${VALIDATE_VERSION_FAILED}"
    fi
  elif [ $package_manager = "brew" ]; then
    if (
      echo "$1"
      brew info "$2" | grep -i version | cut -d ' ' -f 1
    ) | sort -V | head -1 | grep -iq $1; then
      return "${RESOLVED}"
    else
      log "${ERROR}" "Minimum version requirement $1 failed for candidate $2."
      return "${VALIDATE_VERSION_FAILED}"
    fi
  fi
}

add_to_path() {
  if ! echo $PATH | grep -q "$1"; then
    if [[ "$shell" = "bash" ]]; then
      bash -c "export PATH=\"$PATH:$1\""
    elif [[ "$shell" = "zsh" ]]; then
      zsh -c "export PATH=\"$PATH:$1\""
    elif [[ "$shell" = "fish" ]]; then
      fish -c "set -U fish_user_paths $1 $fish_user_paths"
    fi
  fi
}
