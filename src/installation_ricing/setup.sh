#!/usr/bin/env bash

. ~/project_automator/src/variables.sh
. ~/project_automator/src/utils/common.sh

install_oh_my_zsh() {
	print_info "${INFO}" "Installing Oh-My-ZSH"
	cd ~ || exit "${DIR_NOT_EXISTS}"
	update_shell
	# test -f /usr/bin/zsh && user_shell="/usr/bin/zsh" || test -f /bin/zsh && user_shell="/bin/zsh" || test -f /usr/bin/bash && user_shell="/usr/bin/bash" || user_shell="/bin/bash"
	is_pkg_installed zsh && already_installed_pkgs+=('zsh') || {
		install_pkgs pacman zsh
		sudo usermod -s "${user_shell}" "${USER}"
	}
	[[ $(echo "${SHELL}") =~ "bash" ]] && {
		print_info "${INFO}" "Bash is detected as your default shell, changing it to ZSH"
		sudo usermod -s "${user_shell}" "${USER}"
	}
	test -d ~/.oh-my-zsh && {
		print_info "${INFO}" ".oh-my-zsh already installed, not installing again."
		successful_pkgs+=('oh-my-zsh')
		# print_info "${INFO}" "Directory .oh-my-zsh already exists, backing it up to ~/.oh-my-zsh.backup-$(date +"%Y-%m-%d") and then overwriting"
		# sudo cp -r ~/.oh-my-zsh ~/.oh-my-zsh.backup-"$(date +"%Y-%m-%d")"
		# rm -rf ~/.oh-my-zsh
	} || {
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
		git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
		git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
		sed -i "/ZSH_THEME=\"robbyrussell\"/ s/robbyrussell/powerlevel10k\/powerlevel10k/" ~/.zshrc
		sed -i "/plugins=(git)/ a\\\tarchlinux\n\tgit\n\thistory-substring-search\n\tcolored-man-pages\n\tzsh-autosuggestions\n\tzsh-syntax-highlighting\n)" ~/.zshrc
		sed -i "/plugins=(git)/ s/git)//" ~/.zshrc
		successful_pkgs+=('oh-my-zsh')
	}
}

install_fonts() {
	print_info "${SUCCESS}" "Installing Fonts"
	install_pkgs pacman ttf-dejavu ttf-liberation noto-fonts noto-fonts-emoji
	install_pkgs aur nerd-fonts-terminus powerline-fonts-git
	test -f ~/.config/fontconfig/fonts.conf || {
		sudo mkdir ~/.config/fontconfig
		sudo tee -a ~/.config/fontconfig/fonts.conf >/dev/null <<EOF
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
	}
	sudo ln -s /etc/fonts/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d
	sudo ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d
	sudo ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
	sudo sed -i "/#export FREETYPE_PROPERTIES/ s/#//" /etc/profile.d/freetype2.sh
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
	# ls aliases
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
EOF
	# Flameshot
	# 	cat >>~/.config/i3/config <<EOF
	# # Screenshots
	# bindsym Print exec --no-startup-id flameshot full -c -p ~/Screenshots
	# bindsym Shift+Print exec --no-startup-id flameshot gui
	# EOF
	# Dunst
	mkdir ~/.config/dunst
	wget https://raw.githubusercontent.com/dunst-project/dunst/master/dunstrc ~/.config/dunst
	sudo systemctl enable --user dunst.service
	sudo systemctl start --user dunst.service
	# ranger
	install_pkgs pacman ranger atool ffmpegthumbnailer highlight libcaca mediainfo odt2txt poppler python-chardet transmission-cli ueberzug w3m
	# imagemagick
	install_pkgs pacman imagemagick ghostscript libwmf ocl-icd
	# bash-insulter
	git clone https://github.com/hkbakke/bash-insulter.git bash-insulter
	sudo cp bash-insulter/src/bash.command-not-found /etc/
	cat >>~/.zshrc <<EOF
if [ -f /etc/bash.command-not-found ]; then
    . /etc/bash.command-not-found
fi
EOF
	# vim
	git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	# misc
	install_pkgs pacman openssh gdisk rofi feh jpegexiforient imagemagick python-pip python-pywal nitrogen python2 p7zip p7zip-plugins unrar tar rsync bash-completion
	cat >>~/.zshrc <<EOF
	# git aliases
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gac='git add . && git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
EOF
	# polybar
	install_pkgs pacman xorg-fonts-misc
	install_pkgs aur ttf-unifont siji-git polybar
	# snap
	install_pkgs aur snapd
	sudo systemctl start snapd
	install_pkgs snap mailspring
	install_pkgs pacman gnome-keyring
	# docker
	sudo tee /etc/modules-load.d/loop.conf <<<"loop" # enable the loop module
	modprobe loop
	sudo pacman -S docker
	sudo systemctl start docker.service
	sudo systemctl enable docker.service
	sudo groupadd docker
	sudo usermod -aG docker "${USER}"
}

install_ricing() {
	divider "START: Ricing Installation"
	git clone https://github.com/basantech89/arch-ricing ~/arch-ricing
	cd ~ || exit "${HOME_DIR_NOT_EXIST}"
	sudo cp -r arch-ricing ./
	install_oh_my_zsh
	install_fonts
	install_tools
	divider "END: Ricing Installation"
} > >(sudo tee -i ~/project_automator/installation_ricing.log) 2> >(sudo tee -i ~/project_automator/installation_error_ricing.log >&2)
