#!/usr/bin/env bash

. ./src/variables.sh

install_oh_my_zsh() {
	print_info "${SUCCESS}" "Installing Oh-My-ZSH"
	cd ~ || exit "${DIR_NOT_EXISTS}"
	sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
	git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	sed -i "/ZSH_THEME=\"robbyrussell\"/ s/robbyrussell/powerlevel10k\/powerlevel10k/" ~/.zshrc
	sed -i "/plugins=(git)/ a\\\tarchlinux\n\tgit\n\thistory-substring-search\n\tcolored-man-pages\n\tzsh-autosuggestions\n\tzsh-syntax-highlighting\n)" zshrc
	sed -i "/plugins=(git)/ s/git)//" ~/.zshrc
}

install_fonts() {
	print_info "${SUCCESS}" "Installing Fonts"
	install_pkgs pacman nerd-fonts-terminus ttf-dejavu ttf-liberation noto-fonts noto-fonts-emoji
	install_pkgs aur powerline-fonts-git
	sudo tee -a /etc/X11/xorg.conf.d/40-libinput.conf >/dev/null <<EOF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
	<alias>
		<family>sans-serif</family>
		<prefer>
			<family>Noto Sans</family>
			<family>Noto Color Emoji</family>
			<family>Noto Emoji</family>
			<family>DejaVu Sans</family>
		</prefer>
	</alias>

	<alias>
		<family>serif</family>
		<prefer>
			<family>Noto Serif</family>
			<family>Noto Color Emoji</family>
			<family>Noto Emoji</family>
			<family>DejaVu Serif</family>
		</prefer>
	</alias>

	<alias>
		<family>monospace</family>
		<prefer>
			<family>Noto Mono</family>
			<family>Noto Color Emoji</family>
			<family>Noto Emoji</family>
		</prefer>
	</alias>
</fontconfig>
EOF
	sudo ln -s /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
	sudo ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
	sudo ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
	sed -i "/#export FREETYPE_PROPERTIES/ s/#//" /etc/profile.d/freetype2.sh
	sudo tee -a /etc/fonts/local.conf >/dev/null <<EOF
<?xml version="1.0"?>
	<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
  	<fontconfig>
		<match>
			<edit mode="prepend" name="family"><string>Noto Sans</string></edit>
	    </match>
		<match target="pattern">
			<test qual="any" name="family"><string>serif</string></test>
      		<edit name="family" mode="assign" binding="same"><string>Noto Serif</string></edit>
		</match>
		<match target="pattern">
			<test qual="any" name="family"><string>sans-serif</string></test>
			<edit name="family" mode="assign" binding="same"><string>Noto Sans</string></edit>
		</match>
		<match target="pattern">
			<test qual="any" name="family"><string>monospace</string></test>
			<edit name="family" mode="assign" binding="same"><string>Noto Mono</string></edit>
		</match>
	</fontconfig>
EOF
}

install_tools() {
	print_info "${SUCCESS}" "Installing Tools"
	install_pkgs aur st-luke-git libxft-bgra
	install_pkgs pacman lsd flameshot dunst
	# LSD
	cat >>~/.zshrc <<EOF
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
EOF
	# Flameshot
	cat >>~/.config/i3/config <<EOF
# Screenshots
bindsym Print exec --no-startup-id flameshot full -c -p ~/Screenshots
bindsym Shift+Print exec --no-startup-id flameshot gui
EOF
	# Dunst
	mkdir ~/.config/dunst
	wget https://raw.githubusercontent.com/dunst-project/dunst/master/dunstrc ~/.config/dunst
	sudo systemctl enable --user dunst.service
	sudo systemctl start --user dunst.service
	# snap
	install_pkgs aur snapd
	sudo systemctl start snapd
	install_pkgs snap mailspring
	install_pkgs pacman gnome-keyring
	#docker
	sudo tee /etc/modules-load.d/loop.conf <<<"loop" # enable the loop module
	modprobe loop
	sudo pacman -S docker
	sudo systemctl start docker.service
	sudo systemctl enable docker.service
	sudo groupadd docker
	sudo usermod -aG docker "${USER}"
	# misc
	install_pkgs aur polybar
	install_pkgs pacman openssh gdisk rofi feh ranger w3m imagemagick python-pip python-pywal p7zip p7zip-plugins unrar tar rsync
}

install_ricing() {
	divider "START: Ricing Installation"
	git clone https://github.com/basantech89/arch-ricing ~/arch-ricing
	cd ~/arch-ricing || exit
	cp -r * ../
	install_oh_my_zsh
	install_fonts
	install_tools
	divider "END: Ricing Installation"
} > >(tee -i installation_ricing.log) 2> >(tee -i installation_error_ricing.log >&2)
