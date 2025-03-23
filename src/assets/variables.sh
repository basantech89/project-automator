#!/usr/bin/env bash

# Reserved codes = 1, 2, 126, 127, 128, 128+n, 130, 255\*
RESOLVED=0
RESOLVED_WITH_PKG_HELPER=3
PKG_NOT_EXISTS=4
DIR_NOT_EXISTS=5
NOT_SUDO_USER=6
PARTITION_NOT_FOUND=7
PKG_MANAGER_NOT_FOUND=8
PKG_MANAGER_NOT_SUPPORTED=9
PKG_NOT_INSTALLED=12
OS_NOT_FOUND=10
OS_NOT_SUPPORTED=11
SYSTEM_UPDATE_FAILED=13
FONT_NOT_INSTALLED=14
VALIDATE_VERSION_FAILED=15

successful_pkgs=()
failed_pkgs=()
already_installed_pkgs=()

os_name=$(uname -s)
package_manager=""
declare -A abbrs
