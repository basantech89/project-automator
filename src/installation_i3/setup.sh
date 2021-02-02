#!/usr/bin/env bash

. ./src/utils/common.sh

install_file_system_config() {
  install_pkgs pacman mtpfs ntfs-3g pcmanfm
  install_pkgs aur jmtpfs
}

install_i3() {
  divider "START: I3 Window Manager Installation"
  update_system
  install_pkgs pacman openssl xorg xorg-xinit xorg-server i3-gaps lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings i3status
  install_pkgs aur st-luke-git
  sed -i "/#greeter-session=example-gtk-gnome/ s/#//" /etc/lightdm/lightdm.conf
  sed -i "/greeter-session=example-gtk-gnome/ s/example-gtk-gnome/lightdm-gtk-greeter/" /etc/lightdm/lightdm.conf
  sudo systemctl disable gdm -f
  sudo systemctl enable lightdm.service -f
  sudo systemctl set-default graphical.target
  install_file_system_config
  divider "END: I3 Window Manager Installation"
} > >(sudo tee -i installation_i3.log) 2> >(sudo tee -i installation_error_i3.log >&2)
