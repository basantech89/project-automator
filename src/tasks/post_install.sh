#!/usr/bin/env bash

show_summary() {
  log "${SUCCESS}" "Successfully Installed Packages: ${successful_pkgs[*]}"
  log "${ERROR}" "Failed Packages: ${failed_pkgs[*]}"
  log "${WARN}" "Already Installed Packages: ${already_installed_pkgs[*]}"
  {
    log "${SUCCESS}" "Successfully Installed Packages: ${successful_pkgs[*]}"
    log "${ERROR}" "Failed Packages: ${failed_pkgs[*]}"
    log "${WARN}" "Already Installed Packages: ${already_installed_pkgs[*]}"
  } >>$HOME/project-automator.log
}

add_abbreviations() {
  if [ "$package_manager" = pacman ]; then
    abbrs[pman]='sudo pacman -Syu --needed --noconfirm'
    abbrs[pu]='paru -Syu --removemake --cleanafter --needed --noconfirm'
  fi

  if [ "$shell" = fish ]; then
    abbrs[sc]='source ~/.config/fish/config.fish'
  elif [ "$shell" = bash ]; then
    abbrs[sc]='source ~/.bashrc'
  elif [ "$shell" = zsh ]; then
    abbrs[sc]='source ~/.zshrc'
  fi

  for abbr in "${!abbrs[@]}"; do
    if [ "$shell" = bash ]; then
      if ! grep -q "alias $abbr" $HOME/.bashrc; then
        echo alias $abbr="\"${abbrs[$abbr]}\"" >>$HOME/.bashrc
      fi
    fi

    if [ "$shell" = zsh ]; then
      if ! grep -q "alias $abbr" $HOME/.zshrc; then
        echo alias $abbr="\"${abbrs[$abbr]}\"" >>$HOME/.zshrc
      fi
    fi

    if [ "$shell" = fish ]; then
      if [ ! -f $HOME/.config/fish/conf.d/abbreviations.fish ]; then
        touch $HOME/.config/fish/conf.d/abbreviations.fish
      fi

      if ! grep -q "abbr -a -- $abbr" $HOME/.config/fish/conf.d/abbreviations.fish >/dev/null 2>&1; then
        fish -C "abbr -a ${abbr} ${abbrs[$abbr]}; abbr >~/.config/fish/conf.d/abbreviations.fish; exit"
      fi
    fi
  done

  if [ "$shell" = fish ]; then
    if ! grep -q "abbr -a hcat highlight -O ansi" $HOME/.config/fish/conf.d/abbreviations.fish; then
      fish -C "abbr -a hcat highlight -O ansi; abbr >~/.config/fish/conf.d/abbreviations.fish; exit"
    fi
  elif [ "$shell" = bash ]; then
    if ! grep -q "alias hcat=\"highlight -O ansi\"" $HOME/.bashrc; then
      echo -e "alias hcat=\"highlight -O ansi\"" >>$HOME/.bashrc
    fi
  elif [ "$shell" = zsh ]; then
    if ! grep -q "alias hcat=\"highlight -O ansi\"" $HOME/.zshrc; then
      echo -e "alias hcat=\"highlight -O ansi\"" >>$HOME/.zshrc
    fi
  fi
}

install_colorls() {
  if ! is_pkg_installed colorls; then
    mark_start "Install Colorls" -t$PACKAGE

    install_pkgs ruby ruby-dev
    echo "$SUDO_PASSWORD" | sudo -S gem install colorls

    if [ $? -eq 0 ]; then
      if test $shell = bash; then
        echo -e "\nsource $(dirname $(gem which colorls))/tab_complete.sh" >>"~/.bashrc"
      elif test $shell = zsh; then
        echo -e "\nsource $(dirname $(gem which colorls))/tab_complete.sh" >>"~/.zshrc"
      fi
    fi

    mark_end "Install Colorls" -t$PACKAGE
  fi

  abbrs[ls]=colorls
  abbrs[la]='colorls -a'
  abbrs[ll]='colorls -l'
  abbrs[lla]='colorls -la'
}

install_appimage_launcher() {
  if ! is_pkg_installed appimagelauncherd; then
    if [ "$package_manager" = 'pacman' ]; then
      install_pkgs appimagelauncher
    elif [ "$package_manager" = 'apt-get' ]; then
      add_apt_repo ppa:appimagelauncher-team/stable
      install_pkgs appimagelauncher
    fi
  fi
}

install_zoxide() {
  if ! is_pkg_installed zoxide; then
    mark_start "Install Zoxide" -t$PACKAGE

    mkdir -p ~/.local/bin
    add_to_path "\$HOME\/.local\/bin"
    source_shell_config

    if [ "$package_manager" = 'brew' ]; then
      install_pkgs zoxide
    elif [ "$package_manager" = 'apt-get' ]; then
      curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
    fi

    if [ $? -eq 0 ]; then
      if [ "$shell" = fish ]; then
        echo -e "\nzoxide init fish | source\n" >>$HOME/.config/fish/config.fish
      elif [ "$shell" = bash ]; then
        echo -e "\neval \"\$(zoxide init bash)\"\n" >>$HOME/.bashrc
      elif [ "$shell" = zsh ]; then
        echo -e "\neval \"\$(zoxide init zsh)\"\n" >>$HOME/.zshrc
      fi
    fi

    mark_end "Install Zoxide" -t$PACKAGE
  fi
}

install_utilities() {
  mark_start "Install Utilities" -t$TITLE

  install_pkgs ncdu peco safe-rm plocate highlight ripgrep

  if [ "$package_manager" = brew ]; then
    install_pkgs fortune
  else
    install_pkgs fortune-mod
  fi

  install_colorls
  install_appimage_launcher
  install_zoxide

  mark_end "Install Utilities" -t$TITLE
}

post_install() {
  mark_start "Post Install" -t$TITLE

  install_utilities
  add_abbreviations
  show_summary

  mark_end "Post Install" -t$TITLE
}
