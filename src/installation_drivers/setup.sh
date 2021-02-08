#!/usr/bin/env bash

. "${HOME}"/project_automator/src/utils/common.sh

confirm_graphics_card() {
	if [ "${1}" -eq 0 ]; then
		print_info "${INFO}" "Nvidia graphics card is detected"
	else
		print_info "${INFO}" "Intel graphics is detected"
	fi
	print_info "${PROMPT}" "Press y|Y if this is correct. Press any other key if it's incorrect"
	read -r response
	if [ "${response}" != 'Y' -a "${response}" != 'y' ]; then
		exit "${INVALID_GRAPHICS_CARD}"
	fi
}

install_graphics() {
	print_info "${INFO}" "Installing Graphics"
	declare -a pkgs=(xorg-server-devel)
	lspci | grep -ie 'nvidia' >/dev/null
	isNvidia=$?
	if [ "${isNvidia}" -eq 0 ]; then
		pkgs+=('nvidia' 'nvidia-utils' 'nvidia-settings' 'opencl-nvidia')
	else
		pkgs+=('xf86-video-intel' 'mesa' 'vulkan-intel')
	fi
	confirm_graphics_card "${isNvidia}"
	install_pkgs pacman "${pkgs[@]}"
	if [ "${isNvidia}" -eq 0 ]; then
		echo 'blacklist nouveau' | sudo tee -a /usr/lib/modprobe.d/nvidia.conf >/dev/null
		echo 'sudo nvidia-smi' | sudo tee -a ~/post_setup.sh >/dev/null
		install_pkgs aur optimus-manager optimus-manager-qt
		sudo systemctl start optimus-manager
		sudo optimus-manager --switch hybrid
		sudo usermod -a -G video "${USER}"
		cat >>~/.config/i3/config <<EOF
Brightness
bindsym \$mod+\$mod1+Up exec light -A 5
bindsym \$mod+\$mod1+Down exec light -U 5
EOF
	else
		cat >>~/.config/i3/config <<EOF
Brightness
bindsym \$mod+\$mod1+Up exec xbacklight -inc +5
bindsym \$mod+\$mod1+Down exec xbacklight -dec +5
EOF
	fi
}

install_battery() {
	print_info "${SUCCESS}" "Installing Power Modules"
	install_pkgs pacman tlp tlp-rdw
	sudo systemctl enable tlp.service
	sudo systemctl enable NetworkManager-dispatcher.service
	sudo systemctl mask systemd-rfkill.service
	sudo systemctl mask systemd-rfkill.socket
}

install_audio() {
	print_info "${SUCCESS}" "Installing Audio"
	install_pkgs pacman pulseaudio pulseaudio-alsa alsa-utils vlc a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora libvorbis libxv wavpack x264 xvidcore gstreamer0.10-plugins
	amixer sset Master unmute
	amixer sset Speaker unmute
	amixer sset Headphone unmute
}

install_touchpad() {
	print_info "${SUCCESS}" "Installing Touchpad"
	install_pkgs pacman xf86-input-libinput
	sudo tee -a /etc/X11/xorg.conf.d/40-libinput.conf >/dev/null <<EOF
Section "InputClass"
	Identifier "libinput touchpad catchall"
  	MatchIsTouchpad "on"
  	MatchDevicePath "/dev/input/event*"
  	Option "NaturalScrolling" "True"
	Option "Tapping" "True"
	Option "TappingDrag" "True"
	Driver "libinput"
EndSection
EOF
	cat >>~/post_installation_notes.txt <<EOF
sudo libinput list-devices
sudo xinput list-props "MSFT0001:01 06CB:CD5F Touchpad"
sudo xinput set-prop "MSFT0001:01 06CB:CD5F Touchpad" "libinput Tapping Enabled" 1
EOF
}

install_bluetooth() {
	print_info "${SUCCESS}" "Installing Bluetooth"
	sudo rfkill unblock bluetooth
	sudo pacman-key --refresh-keys
	install_pkgs pacman pulseaudio-bluetooth pulseaudio-alsa pavucontrol bluez bluez-utils blueman
	sudo systemctl enable bluetooth
	sudo systemctl start bluetooth
	sudo tee -a /etc/bluetooth/main.cf >/dev/null <<EOF
AutoEnable=true
EOF
	mkdir -p ~/.config/pulse
	sudo cp /etc/pulse/* ~/.config/pulse/
	sudo tee -a ~/.config/pulse/default.pa >/dev/null <<EOF
load-module module-switch-on-connect
EOF
	sudo systemctl restart bluetooth
}

install_drivers() {
	divider "START: System Drivers Installation"
	install_graphics
	install_battery
	install_audio
	install_touchpad
	install_bluetooth
	divider "END: System Drivers Installation"
} > >(sudo tee -i installation_drivers.log) 2> >(sudo tee -i installation_error_drivers.log >&2)
