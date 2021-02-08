#!/usr/bin/env bash

set_uefi_mode() {
  if [ -d /sys/firmware/efi/efivars ]; then
    export UEFI_ENABLED='yes'
    print_info "${INFO}" "UEFI mode is detected"
  else
    export UEFI_ENABLED='no'
    print_info "${INFO}" "Legacy mode is detected"
  fi
  print_info "${PROMPT}" "Press y|Y if this is correct. Press any other key if it's incorrect"
  read -r response
  if [ "${response}" != 'Y' -a "${response}" != 'y' ]; then
    if [ "${UEFI_ENABLED}" = 'yes' ]; then
      export UEFI_ENABLED='no'
    else
      export UEFI_ENABLED='yes'
    fi
  fi
}

prompt_root_partition() {
  print_info "${PROMPT}" "Please type the root partition ${NC}"
  read -r root_fs
  print_info "${INFO}" "You provided ${root_fs} as the input. /dev/${root_fs} would be your Root partition."
  print_info "${PROMPT}" "Press y|Y if this is correct. Press any other key to try again"
}

get_root_partition() {
  prompt_root_partition
  while read -r response; do
    case "$response" in
    ["Yy"])
      local PARTITION="/dev/${root_fs}"
      if lsblk "${PARTITION}" >/dev/null 2>&1; then
        export ROOT="${PARTITION}"
      else
        print_info "${ERROR}" "Partition /dev/${root_fs} not found. Exiting."
        exit "${PARTITION_NOT_FOUND}"
      fi
      break
      ;;
    *) prompt_root_partition ;;
    esac
  done
}

select_installation_mode() {
  print_info "${PROMPT}" "Please select installation mode.  ${NC}"
  modes=("Online" "Offline")
  select mode in "${modes[@]}"; do
    case $mode in
    "Online")
      export installation_mode="Online"
      break
      ;;
    "Offline")
      export installation_mode="Offline"
      break
      ;;
    esac
  done
}

mount_root_partition() {
  print_info "${INFO}" "Mounting Root Partition"
  if sudo mount "${ROOT}" /mnt; then
    print_info "${SUCCESS}" "Partition ${ROOT} mounted"
  else
    print_info "${ERROR}" "Not able to mount partition ${ROOT}"
  fi
}

show_info() {
  if [ "${UEFI_ENABLED}" = 'yes' ]; then
    print_info "${BGINFO}" 'UEFI mode is detected'
    print_info "${BGINFO}" "Your EFI partition is ${efi_partition}"
  else
    print_info "${BGINFO}" 'Legacy mode is detected'
    print_info "${BGINFO}" "Your disk is ${disk}"
  fi
  print_info "${BGINFO}" "Your hostname is ${hostname}"
  print_info "${BGINFO}" "Your root password is ${root_password}"
  print_info "${BGINFO}" "Your new user account user name is ${new_username}"
  print_info "${BGINFO}" "Your new user account user password is ${new_user_password}"
  print_info "${BGINFO}" "Your installation mode is ${installation_mode}"
}
