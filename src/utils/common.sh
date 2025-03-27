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
  local value="${2}"
  while read -r response; do
    case "$response" in
    ["Yy"])
      eval export "${value}=${prompt_result}"
      break
      ;;
    *) prompt_variable "${1}" ;;
    esac
  done
}

set_input_variable() {
  local value=$(dialog --clear --stdout --backtitle "$3" --inputbox "$2" 0 0)
  clear

  log "${INFO}" "You provided ${value} as the input."
  log "${PROMPT}" "Press y|Y if this is correct. Press any other key to try again"
  while read -r response; do
    case "$response" in
    ["Yy"])
      eval export "${1}=${value}"
      break
      ;;
    *)
      set_input_variable "${@}"
      break
      ;;
    esac
  done
}

is_font_installed() {
  if fc-list | grep -i "$1" >/dev/null 2>&1; then
    return "${RESOLVED}"
  else
    return "${FONT_NOT_INSTALLED}"
  fi
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
      if is_font_installed "${font_to_look}"; then
        log "${INFO}" "Font ${font_to_look} is already installed."
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
    retry_if_failed wget -O "/tmp/$zip_file" "$download_url" >/dev/null 2>&1

    if [ -f "/tmp/$zip_file" ]; then
      log "${INFO}" "Downloaded ${zip_file} successfully."
    else
      log "${ERROR}" "Failed to download ${zip_file}."
      return "${FONT_NOT_INSTALLED}"
    fi

    unzip "/tmp/$zip_file" -d "/tmp/${font}"

    if find "/tmp/${font}/" -type f -name '*.ttf' | grep ttf; then
      mv /tmp/${font}/*.ttf "$fonts_dir"
    elif find "/tmp/${font}/" -type f -name '*.otf' | grep otf; then
      mv /tmp/${font}/*.otf "$fonts_dir"
    elif find "/tmp/${font}/" -type f -name '*.woff' | grep woff; then
      mv /tmp/${font}/*.woff "$fonts_dir"
    elif find "/tmp/${font}/" -type f -name '*.woff2' | grep woff2; then
      mv /tmp/${font}/*.woff2 "$fonts_dir"
    else
      log "${ERROR}" "No font files found in ${font}."
      return "${FONT_NOT_INSTALLED}"
    fi

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
  if ! $shell -c "echo $PATH | grep -q $1"; then
    if [[ "$shell" = "bash" ]]; then
      if ! grep -q "export PATH=\"\$PATH:.*$1.*\"$" ~/.bashrc; then
        if ! grep -q "export PATH=\"" ~/.bashrc; then
          echo -e "\nexport PATH=\"\$PATH:$1\"" >>$HOME/.bashrc
        else
          sed -i -e "/export PATH=\"\$PATH:\/.*\"/ s/.$//" $HOME/.bashrc
          sed -i -e "/export PATH=\"\$PATH:.*/ s/$/:${1}\"/" $HOME/.bashrc
        fi
      fi
    elif [[ "$shell" = "zsh" ]]; then
      if ! grep -q "export PATH=\"\$PATH:.*$1.*\"$" ~/.zshrc; then
        if ! grep -q "export PATH=\"" ~/.zshrc; then
          echo -e "\nexport PATH=\"\$PATH:$1\"" >>$HOME/.zshrc
        else
          sed -i -e "/export PATH=\"\$PATH:\/.*\"/ s/.$//" $HOME/.zshrc
          sed -i -e "/export PATH=\"\$PATH:.*/ s/$/:${1}\"/" $HOME/.zshrc
        fi
      fi
    elif [[ "$shell" = "fish" ]]; then
      fish -C "fish_add_path $1; exit"
    fi
  fi
}

retry_if_failed() {
  local attempt=1
  local max_attempts=3
  local delay=2

  local arg_list=("$@")
  for i in "${!arg_list[@]}"; do
    local this_element="${arg_list[i]}"
    local next_element="${arg_list[i + 1]}"

    if [[ "$this_element" == "--delay" ]]; then
      delay="${next_element:-2}"
      shift 2
    elif [[ "$this_element" == "--max-attempts" ]]; then
      max_attempts="${next_element:-3}"
      shift 2
    elif [[ "$this_element" == "--exit-failed" ]]; then
      local should_exit_if_failed=true
      shift 1
    fi
  done

  while [[ $attempt -le $max_attempts ]]; do
    if "$@"; then
      break
    fi

    log "${WARN}" "Attempted $attempt times, Max attempts $max_attempts."
    if [[ $attempt -eq $max_attempts ]]; then
      log "${ERROR}" "Failed to execute command ${@} after $max_attempts attempts."

      if [[ -n $should_exit_if_failed ]]; then
        exit $COMMAND_EXEC_FAILED
      else
        break
      fi
    fi

    log "${INFO}" "Command ${@} failed. Retrying in $delay seconds..."
    attempt=$((attempt + 1))
    sleep $delay
    delay=$((delay * 2))
  done
}
