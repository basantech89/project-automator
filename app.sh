#!/usr/bin/env bash

. $PWD/src/exports.sh

AUTOMATOR_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

main() {
  pre_install
  install
  post_install
} > >(tee -i main.log) 2> >(tee -i main_error.log >&2)

main
