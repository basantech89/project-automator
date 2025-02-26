#!/usr/bin/env bash

. ./src/exports.sh

show_summary() {
  log "${SUCCESS}" "Successfully Installed Packages: ${successful_pkgs[*]}"
  log "${ERROR}" "Failed Packages: ${failed_pkgs[*]}"
  log "${WARNING}" "Already Installed Packages: ${already_installed_pkgs[*]}"
  {
    log "${SUCCESS}" "Successfully Installed Packages: ${successful_pkgs[*]}"
    log "${ERROR}" "Failed Packages: ${failed_pkgs[*]}"
    log "${WARNING}" "Already Installed Packages: ${already_installed_pkgs[*]}"
  } >>$HOME/project-automator.log
}

main() {
  pre_install
  install
  show_summary
} > >(tee -i main.log) 2> >(tee -i main_error.log >&2)

main
