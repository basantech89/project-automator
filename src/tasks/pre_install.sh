#!/usr/bin/env bash

pre_install() {
  cd $HOME
  mark_start "Pre-Install" $TITLE

  prompt_user

  break_line
  detect_package_manager

  break_line
  update_system
  break_line

  install_prerequisites

  break_line
  mark_end "Pre-Install" $TITLE
}
