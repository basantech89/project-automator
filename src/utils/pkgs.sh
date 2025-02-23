#!/usr/bin/env bash

detect_package_manager() {
  case "$os_name" in
  Linux)
    distro=$(cat /etc/os-release | grep ^ID_LIKE= | cut -d '=' -f2)
    case "$distro" in
    "ubuntu" | "debian")
      package_manager="apt"
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
  mark_start "System Update"

  if ! sudo -l -U $USER &>/dev/null; then
    log "${ERROR}" "User $USER is not in sudoers list."
    exit $NOT_SUDO_USER
  fi

  case "$package_manager" in
  "apt")
    sudo "$package_manager" update
    ;;
  "pacman")
    sudo "$package_manager" -Sy --noconfirm --needed
    ;;
  esac

  mark_end "System Update"
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
  if test apt list --installed "${1}" | grep -q "${1}" &>/dev/null; then
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
  if test $package_manager = pacman; then
    return is_pkg_installed_arch "$@"
  elif test $package_manager = apt; then
    return is_pkg_installed_apt "$@"
  elif test $package_manager = brew; then
    return is_pkg_installed_brew "$@"
  fi
}

install_pkg_arch() {
  if pacman -Ss "${1}" &>/dev/null; then
    return sudo pacman -S "${@}" --needed --noconfirm
  elif paru -Ss "${1}" &>/dev/null; then
    return paru -Sy "${@}" --removemake --cleanafter --needed --noconfirm --norebuild --noredownload --skipreview
  else
    log "${ERROR}" "Not able to install package ${1}."
    exit $PKG_NOT_INSTALLED
  fi
}

install_pkg_apt() {
  echo before all args "${@}"
  if test apt list "${1}" | grep -q "${1}" &>/dev/null; then
    echo all args "${@}"
    return sudo apt install -y "${@}"
  else
    log "${ERROR}" "Not able to install package ${1}."
    exit $PKG_NOT_INSTALLED
  fi
}

install_pkg_brew() {
  if brew list | grep -q "${1}" &>/dev/null; then
    return brew install "${@}"
  else
    log "${ERROR}" "Not able to install package ${1}."
    exit $PKG_NOT_INSTALLED
  fi
}

install_pkg() {
  if is_pkg_installed "${1}"; then
    already_installed_pkgs+=("${1}")
  else
    mark_start "Installing Package" $SECONDARY

    if test $package_manager = pacman; then
      install_pkg_arch "${@}"
    elif test $package_manager = apt; then
      install_pkg_apt "${@}"
    elif test $package_manager = brew; then
      install_pkg_brew "${@}"
    fi

    [ $? -eq 0 ] && successful_pkgs+=("${1}") || failed_pkgs+=("${1}")
    mark_end "Installing Package" $SECONDARY
  fi
}

install_pkgs() {
  if [ "$1" = "snap" ]; then
    shift
    sudo snap install "${@}"
  else
    for pkg in "${@}"; do
      install_pkg "${@}"
    done
  fi
}
