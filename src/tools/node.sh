#!/usr/bin/env bash

install_nvm() {
  mark_start "Installing Packages nvm" -t$PACKAGE

  retry_if_failed curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash

  if [ $shell = bash ]; then
    if ! grep -q "export NVM_DIR" ~/.bashrc; then
      cat >>~/.bashrc <<EOF

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh" # This loads nvm
[ -s "\$NVM_DIR/bash_completion" ] && \. "\$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF
      source_shell_config
    fi
  fi

  if [ $shell = zsh ]; then
    if ! grep -q "export NVM_DIR" ~/.zshrc; then
      cat >>~/.zshrc <<EOF

export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh" # This loads nvm
[ -s "\$NVM_DIR/bash_completion" ] && \. "\$NVM_DIR/bash_completion"  # This loads nvm bash_completion

EOF
      source_shell_config
    fi
  fi

  if [ $shell = fish ]; then
    fish -c "fisher install jorgebucaran/nvm.fish"
  fi

  [ $? -eq 0 ] && successful_pkgs+=('nvm') || failed_pkgs+=('nvm')

  mark_end "Installing Packages nvm" -t$PACKAGE
}

install_node_with_nvm() {
  if is_pkg_installed nvm; then
    mark_start "Installing Packages node ${node_version}" -t$PACKAGE

    $shell -ic "nvm install ${node_version}"

    if [ $shell = fish ]; then
      fish -c "set --universal nvm_default_version ${node_version}"
    else
      $shell -ic "nvm alias default ${node_version} && nvm use default"
    fi

    if test $shell = fish; then
      fish -C "npm i -g pnpm yarn; exit;"
    elif test $shell = zsh; then
      sed -i -z -e 's/plugins=(\n\tgit/plugins=(\n\tgit\n\tnpm\n\tyarn/' ~/.zshrc
      # else
      # below somehow causes the script to exit
      # $shell -ic "npm i -g pnpm yarn nx"
    fi

    [ $? -eq 0 ] && successful_pkgs+=("node") || failed_pkgs+=('node')

    mark_end "Installing Packages node ${node_version}" -t$PACKAGE
  else
    failed_pkgs+=('node')
  fi
}

install_node() {
  if ! is_pkg_installed nvm; then
    install_nvm
    install_node_with_nvm
  elif (($($shell -ic "nvm list v${node_version} | grep -ic v${node_version}") != 1)); then
    install_node_with_nvm
  else
    log "${INFO}" "Package node ${node_version} is already installed, not installing again."
    already_installed_pkgs+=("node${node_version}")
  fi
}
