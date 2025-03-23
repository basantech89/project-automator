#!/usr/bin/env bash

. ./src/exports.sh

main() {
  rm -f main.log main_error.log
  pre_install
  install
  post_install
} > >(tee -i main.log) 2> >(tee -i main_error.log >&2)

main
