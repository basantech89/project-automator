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
  test "${1}" = quiet || mark_start "System Update" -t$UPDATE

  case "$package_manager" in
  "apt-get")
    echo "$SUDO_PASSWORD" | sudo -S "$package_manager" update
    ;;
  "pacman")
    echo "$SUDO_PASSWORD" | sudo -S "$package_manager" -Sy --noconfirm --needed
    ;;
  esac

  [ $? -eq 0 ] || {
    log "${ERROR}" "System Update failed."
    exit $SYSTEM_UPDATE_FAILED
  }

  test "${1}" = quiet || mark_end "System Update" -t$UPDATE
}

is_pkg_installed_arch() {
  if pacman -Qi "${1}" &>/dev/null; then
    test "$2" = "quiet" && true || log "${INFO}" "Package ${1} is already installed, not installing again."
    return "${RESOLVED}"
  else
    return "${PKG_NOT_INSTALLED}"
  fi
}

is_pkg_installed_apt() {
  if (($(dpkg -l "${1}" 2>&- | grep -c ^ii) == 1)); then
    test "$2" = "quiet" && true || log "${INFO}" "Package ${1} is already installed, not installing again."
    return "${RESOLVED}"
  else
    return "${PKG_NOT_INSTALLED}"
  fi
}

is_pkg_installed_brew() {
  if brew list | grep -q "${1}" &>/dev/null; then
    test "$2" = "quiet" && true || log "${INFO}" "Package ${1} is already installed, not installing again."
    return "${RESOLVED}"
  else
    return "${PKG_NOT_INSTALLED}"
  fi
}

is_pkg_installed() {
  local chosen_shell=${shell:-bash}

  if type -a fish >/dev/null 2>&1 && test $chosen_shell = fish && fish -C "type -a ${1} >/dev/null 2>&1; exit"; then
    test "${2}" = "quiet" && true || log "${INFO}" "Package ${1} is already installed, not installing again."
  elif type -a $chosen_shell >/dev/null 2>&1 && $chosen_shell -ic "type -a ${1} >/dev/null 2>&1"; then
    test "${2}" = "quiet" && true || log "${INFO}" "Package ${1} is already installed, not installing again."
  elif test "$package_manager" = pacman; then
    is_pkg_installed_arch "${@}"
  elif test "$package_manager" = apt-get; then
    is_pkg_installed_apt "${@}"
  elif test "$package_manager" = brew; then
    is_pkg_installed_brew "${@}"
  fi

  [ $? -eq 0 ] && {
    already_installed_pkgs+=("${1}")
    return "${RESOLVED}"
  } || return "${PKG_NOT_INSTALLED}"
}

WAIT_FOR_SEC_IF_NOT_INSTALLED=2

install_pkgs_arch() {
  local options=()
  local pacman_packages=()
  local aur_packages=()
  local failed_arch_packages=()

  for option in "${@}"; do
    if [[ "${option}" == "-*" ]]; then
      options+=("${option}")
    else
      if pacman -Ss "${option}" &>/dev/null; then
        pacman_packages+=("${option}")
      elif paru -Ss "${option}" &>/dev/null; then
        aur_packages+=("${option}")
      else
        log "${ERROR}" "Package ${option} does not exist."
        failed_arch_packages+=("${option}")
      fi
    fi
  done

  if [ ${#pacman_packages[@]} -ne 0 ]; then
    echo "$SUDO_PASSWORD" | sudo -S pacman -S "${pacman_packages[@]}" "${options[@]}" --needed --noconfirm
    if [ $? -eq 0 ]; then
      successful_pkgs+=("${pacman_packages[@]}")
    else
      log "${ERROR}" "Failed to install packages ${pacman_packages[@]}. Retrying after ${WAIT_FOR_SEC_IF_NOT_INSTALLED} second(s)..."
      sleep $WAIT_FOR_SEC_IF_NOT_INSTALLED
      echo "$SUDO_PASSWORD" | sudo -S pacman -S "${pacman_packages[@]}" "${options[@]}" --needed --noconfirm
      [ $? -eq 0 ] && successful_pkgs+=("${pacman_packages[@]}") || failed_pkgs+=("${pacman_packages[@]}")
    fi
  fi

  if [ ${#aur_packages[@]} -ne 0 ]; then
    echo "$SUDO_PASSWORD" | paru -Sy "${aur_packages[@]}" "${options[@]}" --removemake --cleanafter --needed --noconfirm --norebuild --noredownload --skipreview
    if [ $? -eq 0 ]; then
      successful_pkgs+=("${aur_packages[@]}")
    else
      log "${ERROR}" "Failed to install packages ${aur_packages[@]}. Retrying after ${WAIT_FOR_SEC_IF_NOT_INSTALLED} second(s)..."
      sleep $WAIT_FOR_SEC_IF_NOT_INSTALLED
      echo "$SUDO_PASSWORD" | paru -Sy "${aur_packages[@]}" "${options[@]}" --removemake --cleanafter --needed --noconfirm --norebuild --noredownload --skipreview
      [ $? -eq 0 ] && successful_pkgs+=("${aur_packages[@]}") || failed_pkgs+=("${aur_packages[@]}")
    fi
  fi

  if [ ${#failed_arch_packages[@]} -ne 0 ]; then
    log "${ERROR}" "Failed to install packages ${failed_arch_packages[@]}."
    failed_pkgs+=("${failed_arch_packages[@]}")
  fi
}

install_pkgs_apt() {
  local options=()
  local packages=()
  local failed_apt_packages=()

  for option in "${@}"; do
    if [[ "${option}" == "-*" ]]; then
      options+=("${option}")
    else
      if apt-cache show "${1}" >/dev/null 2>&1; then
        packages+=("${option}")
      else
        log "${ERROR}" "Package ${option} does not exist."
        failed_apt_packages+=("${option}")
      fi
    fi
  done

  if [ ${#packages[@]} -ne 0 ]; then
    echo "$SUDO_PASSWORD" | sudo -S apt-get install -y "${packages[@]}" "${options[@]}"
    if [ $? -eq 0 ]; then
      successful_pkgs+=("${packages[@]}")
    else
      log "${ERROR}" "Failed to install packages ${packages[@]}. Retrying after ${WAIT_FOR_SEC_IF_NOT_INSTALLED} second(s)..."
      sleep $WAIT_FOR_SEC_IF_NOT_INSTALLED
      echo "$SUDO_PASSWORD" | sudo -S apt-get install -y "${packages[@]}" "${options[@]}"
      [ $? -eq 0 ] && successful_pkgs+=("${packages[@]}") || failed_pkgs+=("${packages[@]}")
    fi
  fi

  if [ ${#failed_apt_packages[@]} -ne 0 ]; then
    log "${ERROR}" "Failed to install packages ${failed_apt_packages[@]}."
    failed_pkgs+=("${failed_apt_packages[@]}")
  fi
}

install_pkgs_brew() {
  local options=()
  local packages=()
  local failed_brew_packages=()

  for option in "${@}"; do
    if [[ "${option}" == "-*" ]]; then
      options+=("${option}")
    else
      if brew search "${1}" &>/dev/null; then
        packages+=("${option}")
      else
        log "${ERROR}" "Package ${option} does not exist."
        failed_brew_packages+=("${option}")
      fi
    fi
  done

  if [ ${#packages[@]} -ne 0 ]; then
    echo "$SUDO_PASSWORD" | brew install "${packages[@]}" "${options[@]}"
    if [ $? -eq 0 ]; then
      successful_pkgs+=("${packages[@]}")
    else
      log "${ERROR}" "Failed to install packages ${packages[@]}. Retrying after ${WAIT_FOR_SEC_IF_NOT_INSTALLED} second(s)..."
      sleep $WAIT_FOR_SEC_IF_NOT_INSTALLED
      echo "$SUDO_PASSWORD" | brew install "${packages[@]}" "${options[@]}"
      [ $? -eq 0 ] && successful_pkgs+=("${packages[@]}") || failed_pkgs+=("${packages[@]}")
    fi
  fi

  if [ ${#failed_brew_packages[@]} -ne 0 ]; then
    log "${ERROR}" "Failed to install packages ${failed_brew_packages[@]}."
    failed_pkgs+=("${failed_brew_packages[@]}")
  fi
}

install_pkgs() {
  local options=()
  local packages=()
  local package_installer=""

  for option in "${@}"; do
    if [[ "${option}" == "--snap" ]]; then
      package_installer="snap"
    elif [[ "${option}" == "-*" ]]; then
      options+=("${option}")
    else
      packages+=("${option}")
    fi
  done

  local pkgs_to_install=()

  for pkg in "${packages[@]}"; do
    if ! is_pkg_installed "${pkg}"; then
      pkgs_to_install+=("${pkg}")
    fi
  done

  if [[ "${#pkgs_to_install[@]}" -eq 0 ]]; then
    return
  fi

  if [[ "${package_installer}" == "snap" ]]; then
    mark_start "Installing Packages ${pkgs_to_install[@]}" -t$PACKAGE

    echo "$SUDO_PASSWORD" | sudo -S snap install "${options[@]}" "${pkgs_to_install[@]}"
    if [ $? -eq 0 ]; then
      successful_pkgs+=("${pkgs_to_install[@]}")
    else
      log "${WARN}" "Failed to install packages ${pkgs_to_install[@]}. Retrying after ${WAIT_FOR_SEC_IF_NOT_INSTALLED} second(s)..."
      sleep $WAIT_FOR_SEC_IF_NOT_INSTALLED
      echo "$SUDO_PASSWORD" | sudo -S snap install "${options[@]}" "${pkgs_to_install[@]}"
      [ $? -eq 0 ] && successful_pkgs+=("${pkgs_to_install[@]}") || failed_pkgs+=("${pkgs_to_install[@]}")
    fi

    mark_end "Installing Packages ${pkgs_to_install[@]}" -t$PACKAGE

    return
  fi

  mark_start "Installing Packages ${pkgs_to_install[@]}" -t$PACKAGE

  if test $package_manager = pacman; then
    install_pkgs_arch "${pkgs_to_install[@]}" "${options[@]}"
  elif test $package_manager = apt-get; then
    install_pkgs_apt "${pkgs_to_install[@]}" "${options[@]}"
  elif test $package_manager = brew; then
    install_pkgs_brew "${pkgs_to_install[@]}" "${options[@]}"
  fi

  mark_end "Installing Packages ${pkgs_to_install[@]}" -t$PACKAGE
}

add_apt_repo() {
  local ppa=$(echo "${1}" | cut -d ":" -f 2 | cut -d "/" -f 1)

  if [ -n "$ppa" ] && add-apt-repository -L | grep "${ppa}" &>/dev/null 2>&1; then
    log "${INFO}" "PPA ${1} is already added."
  elif add-apt-repository -L | grep "$1"; then
    log "${INFO}" "PPA ${1} is already added."
  else
    mark_start "Adding PPA ${1}" -t$PPA
    echo "$SUDO_PASSWORD" | sudo -S add-apt-repository -y "${1}"
    mark_end "Adding PPA ${1}" -t$PPA
  fi
}

source_shell_config() {
  if [ $shell = bash -a -f ~/.bashrc ]; then
    source ~/.bashrc
  fi

  if [ $shell = zsh -a -f ~/.zshrc ]; then
    $shell -c "source ~/.zshrc"
  fi

  if [ $shell = fish -a -f ~/.config/fish/config.fish ]; then
    $shell -c "source ~/.config/fish/config.fish"
  fi
}

install_dpkg_pkg() {
  local pkg_name=$(echo "${1}" | rev | cut -d "/" -f 1 | rev)
  mark_start "Installing Package $pkg_name" -t$PACKAGE

  wget -qO "/tmp/${pkg_name}" "$1"
  echo "$SUDO_PASSWORD" | sudo -S apt-get install "/tmp/${pkg_name}" -y
  echo "$SUDO_PASSWORD" | sudo -S apt-get -f install -y
  [ $? -eq 0 ] && successful_pkgs+=("$pkg_name") || failed_pkgs+=("$pkg_name")
  rm "/tmp/${pkg_name}"

  mark_end "Installing Package $pkg_name" -t$PACKAGE
}
