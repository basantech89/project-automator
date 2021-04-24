#!/usr/bin/env bash

. ~/project_automator/src/utils/common.sh
. ~/project_automator/src/installation_system/variables.sh

prompt_installation_variables() {
  set_uefi_mode
  if [ "${UEFI_ENABLED}" = 'yes' ]; then
    set_variable "EFI Partition" efi_partition
  else
    set_variable "Disk" disk
  fi
  set_variable "Hostname" hostname
  set_variable "Root Password" root_password
  set_variable "New Username" new_username
  set_variable "New User Password" new_user_password
  select_installation_mode
  show_info
}

pre_installation_check() {
  [ -z "$(ls -A /mnt)" ] && {
    print_info "${ERROR}" "Invalid mount point /mnt detected"
    exit 5
  }
}

select_mirror() {
  print_info "${INFO}" "Selecting fastest mirrors"
  pacman -Syy --noconfirm >/dev/null
  install_pkgs pacman reflector
  reflector -f 12 -l 10 -n 12 --save ./mirrorlist
  cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.orig
  cp ./mirrorlist /etc/pacman.d/mirrorlist
  cp ./mirrorlist "${HOME}/project_automator/"
  cp ./mirrorlist /mnt
}

prepare_system_installation() {
  print_info "${WARNING}" "Before running this script, make sure you have created and formatted your disk"
  print_info "${WARNING}" "and mounted the root partition in /mnt"
  pre_installation_check
  prompt_installation_variables
  divider "Starting Installation"
  if [ "${installation_mode}" = "Online" ]; then
    sed -i "/#\[multilib\]/{n;s/#//}" /etc/pacman.conf
    sed -i "/#\[multilib\]/ s/#//" /etc/pacman.conf
    successful_pkgs+=('base' 'base-devel' 'linux' 'linux-firmware vim sudo')
    pacstrap /mnt base base-devel linux linux-firmware vim sudo
  else
    print_info "${BGINFO}" "Copying ROOT file system for offline installation"
    cp -ax / /mnt # The option (-x) excludes some special directories, as they should not be copied to the new root.
    # copy the kernel image to the new root, in order to keep the integrity of the new system
    cp -vaT /run/archiso/bootmnt/arch/boot/$(uname -m)/vmlinuz-linux /mnt/boot/vmlinuz-linux
  fi
  cp -r "${HOME}"/project_automator /mnt/root
  genfstab -U -p /mnt >>/mnt/etc/fstab
  print_info "${BGINFO}" "CHROOTing to the system"
  arch-chroot /mnt "${HOME}"/project_automator/src/installation_system/chroot_setup.sh
  umount /mnt
  reboot now
} > >(tee -i /mnt/installation_prepare_system.log) 2> >(tee -i /mnt/installation_error_prepare_system.log >&2)
