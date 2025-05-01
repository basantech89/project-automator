#!/usr/bin/env bash

. $PWD/src/utils/pkgs.sh
. $PWD/src/utils/common.sh

. $PWD/src/assets/variables.sh
. $PWD/src/assets/colors.sh

. $PWD/src/tasks/pre_install.sh
. $PWD/src/tasks/post_install.sh
. $PWD/src/tasks/install.sh
. $PWD/src/tasks/pre_requisites.sh
. $PWD/src/tasks/prompts.sh

. $PWD/src/tools/aws-cli.sh
. $PWD/src/tools/browsers.sh
. $PWD/src/tools/common.sh
. $PWD/src/tools/docker.sh
. $PWD/src/tools/fonts.sh
. $PWD/src/tools/node.sh
. $PWD/src/tools/shell.sh
. $PWD/src/tools/starship.sh
