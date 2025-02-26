#!/usr/bin/env bash

pre_install() {
  cd $HOME
  mark_start "Pre-Install" $TITLE

  if ! sudo -nv >/dev/null 2>&1; then
    log "${ERROR}" "User $USER is not in sudoers list."
    exit $NOT_SUDO_USER
  fi

  set_variable "Your Sudo Password" SUDO_PASSWORD

  break_line
  detect_package_manager

  install_pkgs dialog
  prompt_user

  break_line
  update_system
  break_line

  install_prerequisites

  break_line
  mark_end "Pre-Install" $TITLE
}
