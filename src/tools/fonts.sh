#!/usr/bin/env bash

install_maple_mono() {
  if ! is_font_installed maple; then
    retry_if_failed wget https://github.com/subframe7536/maple-font/releases/download/v7.0/MapleMono-NF.zip -O maple-nf.zip
    unzip maple-nf.zip
    mv *.ttf ~/.local/share/fonts
    fc-cache -fv
    rm -f maple-nf.zip
  fi
}

set_terminal_font() {
  if [ $package_manager = 'apt-get' ]; then
    if is_pkg_installed gsettings; then
      local profile=$(gsettings get org.gnome.Terminal.ProfilesList default | tr -d "'")
      gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/ use-system-font false
      gsettings set org.gnome.Terminal.Legacy.Profile:/org/gnome/terminal/legacy/profiles:/:$profile/ font "$1"
    fi
  fi
}

install_fonts() {
  install_nerd_fonts -s CaskaydiaMono "CascadiaMono" -s Terminess Terminus -s ComicShanns ComicShannsMono
  install_maple_mono
  set_terminal_font "ComicShannsMono Nerd Font 14"
}
