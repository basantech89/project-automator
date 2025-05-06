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

    if [ $node_version = 'lts' -a $package_manager = 'apt-get' ]; then
      run_shell "nvm install --lts"
    else
      run_shell "nvm install ${node_version}"
    fi

    if [ $shell = fish ]; then
      fish -c "set --universal nvm_default_version ${node_version}"
    else
      run_shell "nvm alias default ${node_version} && nvm use default"
    fi

    run_shell "npm i -g pnpm yarn"
    if test $shell = zsh; then
      sed -i -z -e 's/plugins=(\n\tgit/plugins=(\n\tgit\n\tnpm\n\tyarn/' ~/.zshrc
    fi

    [ $? -eq 0 ] && successful_pkgs+=("node") || failed_pkgs+=('node')

    mark_end "Installing Packages node ${node_version}" -t$PACKAGE
  else
    failed_pkgs+=('node')
  fi
}

install_fnm() {
  if ! is_pkg_installed fnm; then
    mark_start "Installing Packages fnm" -t$PACKAGE

    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
    [ $? -eq 0 ] && successful_pkgs+=('fnm') || failed_pkgs+=('fnm')

    if [ $shell = bash ]; then
      cat >>~/.bashrc <<EOF

# fnm
FNM_PATH="\$HOME/.local/share/fnm"
EOF
    elif [ $shell = zsh ]; then
      cat >>~/.zshrc <<EOF

# fnm
FNM_PATH="\$HOME/.local/share/fnm"
EOF
    elif [ $shell = fish ]; then
      cat >>~/.config/fish/conf.d/fnm.fish <<EOF
      
# fnm
set FNM_PATH "\$HOME/.local/share/fnm"
EOF
    fi

    add_to_path "\$FNM_PATH"

    if [ $shell = bash ]; then
      cat >>~/.bashrc <<EOF

if [ -d "\$FNM_PATH" ]; then
  eval "\$(fnm env)"
fi

eval "\$(fnm env --use-on-cd --shell bash)"
EOF
    elif [ $shell = zsh ]; then
      cat >>~/.zshrc <<EOF

if [ -d "\$FNM_PATH" ]; then
  eval "\$(fnm env)"
fi

eval "\$(fnm env --use-on-cd --shell zsh)"
EOF
    elif [ $shell = fish ]; then
      cat >>~/.config/fish/conf.d/fnm.fish <<EOF

if [ -d "\$FNM_PATH" ]
  fnm env | source
end

fnm env --use-on-cd --shell fish | source
EOF
    fi

    if [ $shell = bash ]; then
      run_shell "fnm completions --shell bash >>~/.config/fnm_completions.sh"
      echo "source ~/.config/fnm_completions.sh" >>~/.bashrc
    elif [ $shell = zsh ]; then
      run_shell "fnm completions --shell zsh >>~/.config/fnm_completions.sh"
      echo "source ~/.config/fnm_completions.sh" >>~/.zshrc
    elif [ $shell = fish ]; then
      run_shell "fnm completions --shell fish >>~/.config/fish/completions/fnm_completions.fish"
    fi

    mark_end "Installing Packages fnm" -t$PACKAGE
  fi
}

install_node_with_fnm() {
  if is_pkg_installed fnm; then
    mark_start "Installing Packages node ${node_version}" -t$PACKAGE

    if [ "$node_version" = 'lts' ]; then
      run_shell "fnm install --lts"
    else
      run_shell "fnm install ${node_version}"
    fi

    local node_installed_version=$(run_shell "fnm current")
    run_shell "fnm alias default $node_installed_version && fnm use default"

    run_shell "npm i -g pnpm yarn"
    if test $shell = zsh; then
      sed -i -z -e 's/plugins=(\n\tgit/plugins=(\n\tgit\n\tnpm\n\tyarn/' ~/.zshrc
    fi

    [ $? -eq 0 ] && successful_pkgs+=("node") || failed_pkgs+=('node')

    mark_end "Installing Packages node ${node_version}" -t$PACKAGE
  else
    failed_pkgs+=('node')
  fi
}

# install_node() {
#   if ! is_pkg_installed nvm; then
#     install_nvm
#     install_node_with_nvm
#   elif (($($shell -ic "nvm list v${node_version} | grep -ic v${node_version}") != 1)); then
#     install_node_with_nvm
#   else
#     log "${INFO}" "Package node ${node_version} is already installed, not installing again."
#     already_installed_pkgs+=("node${node_version}")
#   fi
# }

install_node() {
  if ! is_pkg_installed fnm; then
    install_fnm
    install_node_with_fnm
  elif (($(run_shell "fnm list | grep -ic ${node_version}") != 1)); then
    install_node_with_fnm
  else
    log "${INFO}" "Package node ${node_version} is already installed, not installing again."
    already_installed_pkgs+=("node${node_version}")
  fi
}
