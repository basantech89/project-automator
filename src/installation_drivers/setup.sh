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
	declare -a pkgs=('xorg-server-devel' 'xf86-video-intel' 'mesa' 'mesa-vdpau' 'libva-mesa-driver' 'vulkan-driver' 'vulkan-intel')
	lspci | grep -ie 'nvidia' >/dev/null
	isNvidia=$?
	if [ "${isNvidia}" -eq 0 ]; then
		pkgs+=('nvidia' 'nvidia-utils' 'nvidia-settings' 'opencl-nvidia' 'libvdpau')
	fi
	confirm_graphics_card "${isNvidia}"
	install_pkgs pacman "${pkgs[@]}"
	if [ "${isNvidia}" -eq 0 ]; then
		echo "blacklist nouveau" | sudo tee -a /usr/lib/modprobe.d/nvidia.conf >/dev/null
		tee a ~/project_automator/post_run.sh >/dev/null <<EOF
# after reboot
sudo nvidia-smi
sudo systemctl start optimus-manager
sudo optimus-manager --switch hybrid
EOF
		install_pkgs aur optimus-manager optimus-manager-qt
		sudo usermod -a -G video "${USER}"
		cat >>~/project_automator/post_run.sh <<EOF
cat >>~/.config/i3/config <<DONE
# Brightness
bindsym \$mod+\$mod1+Up exec light -A 5
bindsym \$mod+\$mod1+Down exec light -U 5
DONE
EOF
	else
		cat >>~/project_automator/post_run.sh <<EOF
cat >>~/.config/i3/config <<DONE
# Brightness
bindsym \$mod+\$mod1+Up exec xbacklight -inc +5
bindsym \$mod+\$mod1+Down exec xbacklight -dec +5
DONE
EOF
	fi
}

install_battery() {
	print_info "${SUCCESS}" "Installing Power Modules"
	install_pkgs pacman ethtool lsb-release smartmontools x86_energy_perf_policy tlp tlp-rdw
	sudo systemctl enable tlp.service
	sudo systemctl enable NetworkManager-dispatcher.service
	sudo systemctl mask systemd-rfkill.service
	sudo systemctl mask systemd-rfkill.socket
}

install_audio() {
	print_info "${SUCCESS}" "Installing Audio"
	# intel architecture families
	# >= Broadwell --> intel-media-driver
	# <= Haswell --> libva-intel-driver
	install_pkgs pacman libva-vdpau-driver intel-media-driver libavtp libsamplerate fftw celt libffado realtime-privileges avisynthplus ladspa sdl gst-plugins-base-libs libdc1394 gnu-free-fonts twolame mpg123 aalib libcaca pulseaudio-alsa pulseaudio-lirc pulseaudio-jack pulseaudio-zeroconf pulseaudio-bluetooth pulseaudio-equalizer pulseaudio-rtp pulseaudio alsa-utils vlc a52dec faac faad2 flac jasper lame libdca libdv libmad libmpeg2 libtheora libvorbis libxv wavpack x264 xvidcore
	install_pkgs aur gstreamer0.10-base-plugins
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
	Option "AccelSpeed" "0.8"
	Driver "libinput"
EndSection
EOF
}

install_bluetooth() {
	print_info "${SUCCESS}" "Installing Bluetooth"
	sudo rfkill unblock bluetooth
	sudo pacman-key --refresh-keys
	install_pkgs pacman pulseaudio-bluetooth pulseaudio-alsa pavucontrol bluez bluez-utils blueman
	sudo systemctl enable bluetooth
	sudo systemctl start bluetooth
	#	sudo tee -a /etc/bluetooth/main.cf >/dev/null <<EOF
	sudo tee -a /etc/bluetooth/main.conf >/dev/null <<EOF
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
} > >(tee -i ~/project_automator/installation_drivers.log) 2> >(tee -i ~/project_automator/installation_error_drivers.log >&2)
