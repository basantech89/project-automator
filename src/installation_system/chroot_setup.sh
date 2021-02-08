#!/usr/bin/env bash

. ~/project_automator/src/utils/common.sh

install_bootloader() {
	if [ "${UEFI_ENABLED}" = 'yes' ]; then
		install_pkgs pacman grub efibootmgr dosfstools os-prober mtools
		mkdir /boot/efi
		mount "/dev/${efi_partition}" /boot/efi
		grub-install --target=x86_64-efi --bootloader-id=GRUB --efi-directory=/boot/efi --removable
		grub-mkconfig -o /boot/grub/grub.cfg
	else
		install_pkgs pacman grub os-prober
		grub-install "/dev/${disk}"
		grub-mkconfig -o /boot/grub/grub.cfg
	fi
} > >(tee -i bootloader.log) 2> >(tee -i bootloader_error.log >&2)

config_network() {
	echo "${hostname}" >/etc/hostname
	cat >>/etc/hosts <<EOF
127.0.0.1	localhost
::1		localhost
127.0.1.1	${hostname}
EOF
	[[ "${installation_mode}" = "Online" ]] && {
		install_pkgs pacman networkmanager openssh
		systemctl enable NetworkManager
	}
}

config_offline() {
	# This customization of archiso will lead to storing the system journal in RAM, it means that the journal will not be available after reboot
	sed -i 's/Storage=volatile/#Storage=auto/' /etc/systemd/journald.conf
	# This rule of udev starts the dhcpcd automatically if there are any wired network interfaces.
	rm /etc/udev/rules.d/81-dhcpcd.rules
	# Disable and remove the services created by archiso
	# Some service files are created for the Live environment, please disable the services and remove the file as they are unnecessary for the new system:
	systemctl disable pacman-init.service choose-mirror.service
	rm -r /etc/systemd/system/{choose-mirror.service,pacman-init.service,etc-pacman.d-gnupg.mount,getty@tty1.service.d}
	rm /etc/systemd/scripts/choose-mirror
	# Remove special scripts of the Live environment
	#There are some scripts installed in the live system by archiso scripts, which are unnecessary for the new system
	rm /etc/systemd/system/getty@tty1.service.d/autologin.conf
	rm /root/{.automated_script.sh,.zlogin}
	rm /etc/mkinitcpio-archiso.conf
	rm -r /etc/initcpio
	# Importing archlinux keys
	#In order to use the official repositories, we need to import the archlinux master keys (pacman/Package signing#Initializing the keyring). This step is usually done by pacstrap but can be achieved with
	pacman-key --init
	pacman-key --populate archlinux
}

config_system() {
	if [ "${installation_mode}" = "Offline" ]; then
		config_offline
	fi
	# locale
	sed -i "/#en_IN UTF-8/ s/#//" /etc/locale.gen
	locale-gen
	echo LANG=en_US.UTF-8 >/etc/locale.conf
	export LANG=en_US.UTF-8
	# timezone and clock
	timedatectl set-timezone Asia/Kolkata
	hwclock --systohc --utc
	config_network
	# multilib repo
	sed -i "/#\[multilib\]/{n;s/#//}" /etc/pacman.conf
	sed -i "/#\[multilib\]/ s/#//" /etc/pacman.conf
	update_system
	# user setup
	echo "root:${root_password}" | chpasswd
	update_shell
	useradd -m -g users -G wheel,storage,power -s "${user_shell}" "${new_username}"
	echo "${new_username}:${new_user_password}" | chpasswd
	#  chage -d 0 "${new_username}"
	sed -i "/# %wheel ALL=(ALL) ALL/ s/# //" /etc/sudoers
	if [ "${installation_mode}" = "Offline" ]; then
		mkinitcpio -P
	else
		install_pkgs pacman linux-lts
	fi

	install_bootloader
	exit
}

config_system
