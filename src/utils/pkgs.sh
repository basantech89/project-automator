#!/usr/bin/env bash

detect_package_manager() {
  case "$os_name" in
  Linux)
    distro=$(cat /etc/os-release | grep ^ID_LIKE= | cut -d '=' -f2)
    case "$distro" in
    "ubuntu" | "debian")
      package_manager="apt-get"
      ;;
    "centos" | "rhel")
      log "${ERROR}" "CentOS/RHEL is not yet supported."
      exit $PKG_MANAGER_NOT_SUPPORTED
      ;;
    "fedora")
      log "${ERROR}" "Fedora is not yet supported."
      exit $PKG_MANAGER_NOT_SUPPORTED
      ;;
    "arch")
      package_manager="pacman"
      ;;
    *)
      log "${ERROR}" "Package Manager not found."
      exit $PKG_MANAGER_NOT_FOUND
      ;;
    esac
    ;;
  Darwin)
    log "${ERROR}" "macOS is not yet supported."
    exit $OS_NOT_SUPPORTED
    ;;
  *)
    log "${ERROR}" "Operating System not found."
    exit $OS_NOT_FOUND
    ;;
  esac

  log "${INFO}" "Operating System: $os_name"
  log "${INFO}" "Package Manager: $package_manager"
}

update_system() {
  test "${1}" = quiet || mark_start "System Update"

  case "$package_manager" in
  "apt-get")
    echo "$SUDO_PASSWORD" | sudo "$package_manager" update
    ;;
  "pacman")
    echo "$SUDO_PASSWORD" | sudo "$package_manager" -Sy --noconfirm --needed
    ;;
  esac

  [ $? -eq 0 ] || {
    log "${ERROR}" "System Update failed."
    exit $SYSTEM_UPDATE_FAILED
  }

  test "${1}" = quiet || mark_end "System Update"
}

is_pkg_installed_arch() {
  if pacman -Qi "${1}" &>/dev/null; then
    test "$2" = "quiet" && log "${INFO}" "Package ${1} is already installed, not installing again"
    return "${RESOLVED}"
  elif which "${1}" &>/dev/null; then
    test "$2" = "quiet" && log "${INFO}" "Package ${1} is already installed, not installing again"
    return "${RESOLVED}"
  else
    log "${INFO}" "Installing Package ${1}"
    return "${PKG_NOT_EXISTS}"
  fi
}

is_pkg_installed_apt() {
  if (($(dpkg -l "${1}" 2>&- | grep -c ^ii) == 1)); then
    return "${RESOLVED}"
  else
    return "${PKG_NOT_INSTALLED}"
  fi
}

is_pkg_installed_brew() {
  if brew list | grep -q "${1}" &>/dev/null; then
    return "${RESOLVED}"
  else
    return "${PKG_NOT_INSTALLED}"
  fi
}

is_pkg_installed() {
  if test "$package_manager" = pacman; then
    is_pkg_installed_arch "${@}"
  elif test "$package_manager" = apt-get; then
    is_pkg_installed_apt "${@}"
  elif test "$package_manager" = brew; then
    is_pkg_installed_brew "${@}"
  fi
}

install_pkg_arch() {
  if pacman -Ss "${1}" &>/dev/null; then
    echo "$SUDO_PASSWORD" | sudo pacman -S "${@}" --needed --noconfirm
  elif paru -Ss "${1}" &>/dev/null; then
    paru -Sy "${@}" --removemake --cleanafter --needed --noconfirm --norebuild --noredownload --skipreview
  else
    log "${ERROR}" "Not able to install package ${1}."
    exit $PKG_NOT_INSTALLED
  fi
}

install_pkg_apt() {
  if apt-cache show "${1}" >/dev/null 2>&1; then
    echo "$SUDO_PASSWORD" | sudo apt-get install -y "${@}"
  else
    log "${ERROR}" "Not able to install package ${1}."
    exit $PKG_NOT_INSTALLED
  fi
}

install_pkg_brew() {
  if brew list | grep -q "${1}" &>/dev/null; then
    brew install "${@}"
  else
    log "${ERROR}" "Not able to install package ${1}."
    exit $PKG_NOT_INSTALLED
  fi
}

install_pkg() {
  if is_pkg_installed "${1}"; then
    already_installed_pkgs+=("${1}")
  else
    mark_start "Installing Package ${1}" $SUCCESS

    if test $package_manager = pacman; then
      install_pkg_arch "${@}"
    elif test $package_manager = apt-get; then
      install_pkg_apt "${@}"
    elif test $package_manager = brew; then
      install_pkg_brew "${@}"
    fi

    [ $? -eq 0 ] && successful_pkgs+=("${1}") || failed_pkgs+=("${1}")
    mark_end "Installing Package ${1}" $SUCCESS
  fi
}

install_pkgs() {
  local options=()
  local packages=()
  local package_installer=""

  for option in "${@}"; do
    if [[ "${option}" == "--snap" ]]; then
      package_installer="snap"
    elif [[ "${option}" == "--*" ]]; then
      options+=("${option}")
    else
      packages+=("${option}")
    fi
  done

  if [[ "${package_installer}" == "snap" ]]; then
    for pkg in "${packages}"; do
      echo "$SUDO_PASSWORD" | sudo snap install "${options[@]}" "${pkg}"
      [ $? -eq 0 ] && successful_pkgs+=("${1}") || failed_pkgs+=("${1}")
    done

    return
  fi

  for pkg in "${packages[@]}"; do
    install_pkg "${pkg}" "${options[@]}"
  done
}

add_apt_repo() {
  local ppa=$(echo "${1}" | cut -d ":" -f 2 | cut -d "/" -f 1)
  if sudo add-apt-repository -L | grep "${ppa}" &>/dev/null 2>&1; then
    log "${INFO}" "PPA ${1} is already added."
  else
    mark_start "Adding PPA ${1}" $SECONDARY
    echo "$SUDO_PASSWORD" | sudo add-apt-repository -y "${1}"
    update_system quiet
    mark_end "Adding PPA ${1}" $SECONDARY
  fi

}

source_shell_config() {
  if [ $shell = bash -a -f ~/.bashrc ]; then
    source ~/.bashrc
  fi

  if [ $shell = zsh -a -f ~/.zshrc ]; then
    source ~/.zshrc
  fi

  if [ $shell = fish -a -f ~/.config/fish/config.fish ]; then
    source ~/.config/fish/config.fish
  fi
}
