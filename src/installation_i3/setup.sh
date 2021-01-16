#!/usr/bin/env bash

. ./src/utils/common.sh

install_yay() {
  cd ~ || exit
  is_pkg_installed fakeroot || install_pkgs pacman base-devel
  git clone https://aur.archlinux.org/yay.git
  cd yay || exit
  makepkg -si --noconfirm
  cd ~ || exit
  successful_pkgs+=('yay')
}

install_file_system_config() {
  install_pkgs pacman mtpfs ntfs-3g pcmanfm
  install_pkgs yay jmtpfs
}

install_i3() {
  update_system
  install_pkgs pacman dialog wpa_supplicant openssl xorg xorg-xinit xorg-server i3-gaps lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings i3status git
  sed -i "/#greeter-session=example-gtk-gnome/ s/#//" /etc/lightdm/lightdm.conf
  sed -i "/greeter-session=example-gtk-gnome/ s/example-gtk-gnome/lightdm-gtk-greeter/" /etc/lightdm/lightdm.conf
  sudo systemctl disable gdm -f
  sudo systemctl enable lightdm.service -f
  sudo systemctl set-default graphical.target
  install_yay
  install_file_system_config
}
