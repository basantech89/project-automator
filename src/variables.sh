#!/usr/bin/env bash

# Reserved codes = 1, 2, 126, 127, 128, 128+n, 130, 255\*
RESOLVED=0
INVALID_GRAPHICS_CARD=3
PKG_NOT_EXISTS=4
DIR_NOT_EXISTS=5
ROOT_USER_NOT_SUPPORTED=6
PARTITION_NOT_FOUND=7
HOME_DIR_NOT_EXIST=8

successful_pkgs=()
failed_pkgs=()
already_installed_pkgs=()
