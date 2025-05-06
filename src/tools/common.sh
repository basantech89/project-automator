#!/usr/bin/env bash

install_neovim() {
  if test $package_manager = apt-get; then
    install_pkgs python3-dev python3-pip
  fi

  if ! is_pkg_installed nvim; then
    if validate_version 0.8.0 neovim; then
      install_pkgs neovim
    else
      mark_start "Installing Package nvim" -t$PACKAGE

      retry_if_failed curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
      echo "$SUDO_PASSWORD" | sudo -S rm -rf /opt/nvim*
      echo "$SUDO_PASSWORD" | sudo -S tar -C /opt -xzf nvim-linux-x86_64.tar.gz
      rm nvim-linux-x86_64.tar.gz
      add_to_path /opt/nvim-linux-x86_64/bin
      source_shell_config

      [ $? -eq 0 ] && successful_pkgs+=('nvim') || failed_pkgs+=('nvim')
      mark_end "Installing Package nvim" -t$PACKAGE
    fi

    if [[ ! -d ~/.config/nvim ]]; then
      git clone https://github.com/LazyVim/starter ~/.config/nvim
      rm -rf ~/.config/nvim/.git
    fi
  fi

  abbrs[vim]=nvim
}

install_warp_terminal() {
  if ! is_pkg_installed warp-terminal; then
    if [ "$package_manager" = 'pacman' ]; then
      if ! grep -q "warpdotdev" /etc/pacman.conf; then
        echo "$SUDO_PASSWORD" | sudo -S tee -a /etc/pacman.conf >/dev/null <<EOF
[warpdotdev]
Server = https://releases.warp.dev/linux/pacman/\$repo/\$arch

EOF
      fi

      echo "$SUDO_PASSWORD" | sudo -S pacman-key -r "linux-maintainers@warp.dev"
      echo "$SUDO_PASSWORD" | sudo -S pacman-key --lsign-key "linux-maintainers@warp.dev"
      install_pkgs warp-terminal
    elif [ "$package_manager" = 'apt-get' ]; then
      wget -qO- https://releases.warp.dev/linux/keys/warp.asc | gpg --dearmor >warpdotdev.gpg
      echo "$SUDO_PASSWORD" | sudo -S install -D -o root -g root -m 644 warpdotdev.gpg /etc/apt/keyrings/warpdotdev.gpg
      echo "$SUDO_PASSWORD" | sudo -S sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" > /etc/apt/sources.list.d/warpdotdev.list'
      rm warpdotdev.gpg

      update_system quiet
      install_pkgs warp-terminal
    elif [ "$package_manager" = 'brew' ]; then
      install_pkgs --cask warp
    fi

    if [[ ! -d "~/.config/warp-terminal" ]]; then
      mkdir -p ~/.config/warp-terminal
    fi

    cat >~/.config/warp-terminal/user_preferences.json <<EOF
{
  "prefs": {
    "TelemetryBannerDismissed": "true",
    "WelcomeTipsFeaturesUsed": "[{\"Hint\":\"CreateBlock\"}]",
    "ReceivedReferralTheme": "\"Inactive\"",
    "TelemetryEnabled": "true",
    "CrashReportingEnabled": "true",
    "NextCommandSuggestionsUpgradeBannerNumTimesShownThisPeriod": "0",
    "HasAutoOpenedWelcomeFolder": "true",
    "IsSettingsSyncEnabled": "true",
    "InputMode": "\"PinnedToTop\"",
    "SystemTheme": "false",
    "Theme": "\"CyberWave\"",
    "LigatureRenderingEnabled": "true",
    "FontWeight": "\"Normal\"",
    "LineHeightRatio": "1.2",
    "HonorPS1": "true",
    "ShowBlockDividers": "true",
    "OverrideOpacity": "80",
    "AutosuggestionKeybindingHint": "true",
    "IsSettingsSyncEnabled": "true",
    "Spacing": "\"Normal\"",
    "FontSize": "20.0",
    "FontName": "\"CaskaydiaCove Nerd Font\""
  }
}
EOF
  fi
}

install_vscode() {
  if ! is_pkg_installed code; then
    if [ "$package_manager" = 'pacman' ]; then
      install_pkgs visual-studio-code-bin
    elif [ "$package_manager" = 'apt-get' ]; then
      retry_if_failed wget -O- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >/tmp/packages.microsoft.gpg
      echo "$SUDO_PASSWORD" | sudo -S install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
      echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
      rm -f /tmp/packages.microsoft.gpg

      update_system quiet
      install_pkgs code
    elif [ "$package_manager" = 'brew' ]; then
      install_pkgs --cask visual-studio-code
    fi

    [ $? -eq 0 ] && successful_pkgs+=('vscode') || failed_pkgs+=('vscode')
  fi
}

install_postman() {
  if ! is_pkg_installed postman; then
    if [ "$package_manager" = 'pacman' ]; then
      install_pkgs postman-bin
    elif [ "$package_manager" = 'apt-get' ]; then
      mark_start "Installing Postman" -t$PACKAGE

      echo "$SUDO_PASSWORD" | sudo -S rm -rf /opt/Postman
      retry_if_failed tar -C /tmp/ -xzf <(curl -L https://dl.pstmn.io/download/latest/linux64) && echo "$SUDO_PASSWORD" | sudo -S mv /tmp/Postman /opt/
      echo "$SUDO_PASSWORD" | sudo -S ln -s /opt/Postman/Postman /usr/bin/postman
      echo "$SUDO_PASSWORD" | sudo -S tee -a /usr/share/applications/postman.desktop <<END
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Exec=/opt/Postman/Postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
END

      mark_end "Installing Postman" -t$PACKAGE
    elif [ "$package_manager" = 'brew' ]; then
      install_pkgs --cask postman
    fi

    [ $? -eq 0 ] && successful_pkgs+=('postman') || failed_pkgs+=('postman')
  fi
}

install_dbeaver() {
  if ! is_pkg_installed dbeaver; then
    if [ "$package_manager" = 'pacman' ]; then
      install_pkgs dbeaver dbeaver-plugin-office
    elif [ "$package_manager" = 'apt-get' ]; then
      install_dpkg_pkg https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
    elif [ "$package_manager" = 'brew' ]; then
      install_pkgs --cask dbeaver-community
    fi
  fi
}

install_notion() {
  if [ "$package_manager" = 'pacman' ]; then
    install_pkgs notion-app-electron
  elif [ "$package_manager" = 'apt-get' ]; then
    install_pkgs --snap notion-snap-reborn
  elif [ "$package_manager" = 'brew' ]; then
    install_pkgs --cask notion
  fi
}

install_ms_teams() {
  if [ "$package_manager" = 'pacman' ]; then
    install_pkgs teams
  elif [ "$package_manager" = 'apt-get' ]; then
    install_pkgs --snap teams-for-linux
  elif [ "$package_manager" = 'brew' ]; then
    install_pkgs --cask microsoft-teams
  fi
}

install_slack() {
  if [ "$package_manager" = 'brew' ]; then
    install_pkgs --cask slack
  else
    install_pkgs --snap slack
  fi
}
