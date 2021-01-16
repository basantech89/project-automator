#!/usr/bin/env bash

. ./src/utils/common.sh

is_pkg_installed() {
    if ls "${1}" 2>/dev/null; then
        return "${SUCCESS}"
    else
        return "${PKG_NOT_EXISTS}"
    fi
}

is_pkg_installed app.s || echo "nope"
