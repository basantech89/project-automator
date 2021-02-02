#!/usr/bin/env bash

. ./src/utils/common.sh
. ./src/installation_system/variables.sh

prompt_installation_variables() {
  set_uefi_mode
  if [ "${UEFI_ENABLED}" = 'yes' ]; then
    set_variable efi_partition
  else
    set_variable disk
  fi
  set_variable hostname
  set_variable root_password
  set_variable new_username
  set_variable new_user_password
  select_installation_mode
  show_info
}

prepare_system_installation() {
  print_info "${WARNING}" "Before running this script, make sure you have created and formatted your disk"
  print_info "${WARNING}" "and mounted the root partition in /mnt"
  prompt_installation_variables

  divider "Starting Installation"
  if [ "${installation_mode}" = "Online" ]; then
    sed -i "/#\[multilib\]/{n;s/#//}" /etc/pacman.conf
    sed -i "/#\[multilib\]/ s/#//" /etc/pacman.conf
    #  select_mirror
    pacstrap /mnt base base-devel linux linux-firmware vim sudo
  else
    cp -ax / /mnt # The option (-x) excludes some special directories, as they should not be copied to the new root.
    # copy the kernel image to the new root, in order to keep the integrity of the new system
    cp -vaT /run/archiso/bootmnt/arch/boot/$(uname -m)/vmlinuz /mnt/boot/vmlinuz-linux
  fi
  cp ./src/installation_system/chroot_setup.sh /mnt
  genfstab -U -p /mnt >>/mnt/etc/fstab
  arch-chroot /mnt ./chroot_setup.sh
  cp prepare_system_installation.log prepare_system_installation_error.log /mnt
  umount /mnt
  reboot now
} > >(tee -i installation_prepare_system.log) 2> >(tee -i installation_error_prepare_system.log >&2)
