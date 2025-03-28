#!/usr/bin/env bash

. $PWD/project-automator/src/utils/pkgs.sh
. $PWD/project-automator/src/utils/common.sh

. $PWD/project-automator/src/assets/variables.sh
. $PWD/project-automator/src/assets/colors.sh

. $PWD/project-automator/src/tasks/pre_install.sh
. $PWD/project-automator/src/tasks/post_install.sh
. $PWD/project-automator/src/tasks/install.sh
. $PWD/project-automator/src/tasks/pre_requisites.sh
. $PWD/project-automator/src/tasks/prompts.sh

. $PWD/project-automator/src/tools/common.sh
. $PWD/project-automator/src/tools/shell.sh
. $PWD/project-automator/src/tools/dotfiles.sh
