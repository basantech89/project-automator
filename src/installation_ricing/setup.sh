#!/usr/bin/env bash

. ~/project_automator/src/variables.sh
. ~/project_automator/src/utils/common.sh

install_oh_my_zsh() {
	print_info "${INFO}" "Installing Oh-My-ZSH"
	cd ~ || exit "${DIR_NOT_EXISTS}"
	# test -f /usr/bin/zsh && user_shell="/usr/bin/zsh" || test -f /bin/zsh && user_shell="/bin/zsh" || test -f /usr/bin/bash && user_shell="/usr/bin/bash" || user_shell="/bin/bash"
	is_pkg_installed zsh && already_installed_pkgs+=('zsh') || {
		install_pkgs pacman zsh
	}
	[[ $(echo "${SHELL}") =~ "bash" ]] && {
		print_info "${INFO}" "Bash is detected as your default shell, changing it to ZSH"
		update_shell
		sudo usermod -s "${user_shell}" "${USER}"
	}
	test -d ~/.oh-my-zsh && {
		print_info "${INFO}" ".oh-my-zsh already installed, not installing again."
		already_installed_pkgs+=('oh-my-zsh')
		# print_info "${INFO}" "Directory .oh-my-zsh already exists, backing it up to ~/.oh-my-zsh.backup-$(date +"%Y-%m-%d") and then overwriting"
		# sudo cp -r ~/.oh-my-zsh ~/.oh-my-zsh.backup-"$(date +"%Y-%m-%d")"
		# rm -rf ~/.oh-my-zsh
	} || {
		# autojump
		install_pkgs aur autojump
		sudo sed -i '$ . /usr/share/autojump/autojump.zsh' ~/.zshrc
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
		git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
		git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
		git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
		sed -i "/ZSH_THEME=\"robbyrussell\"/ s/robbyrussell/powerlevel10k\/powerlevel10k/" ~/.zshrc
		sed -i "/plugins=(git)/ a\\\tarchlinux\n\tgit\n\thistory-substring-search\n\tcolored-man-pages\n\tzsh-autosuggestions\n\tzsh-syntax-highlighting\n\tautojump\n\tgitignore\n\tnpm\n\tsudo\n\tsystemadmin\n\tyarn\n\tweb-search\n\ttransfer\n)" ~/.zshrc
		sed -i "/plugins=(git)/ s/git)//" ~/.zshrc
		successful_pkgs+=('oh-my-zsh')
	}
}

install_fonts() {
	print_info "${SUCCESS}" "Installing Fonts"
	install_pkgs pacman ttf-dejavu ttf-liberation noto-fonts noto-fonts-emoji noto-fonts-extra ttf-font-awesome
	install_pkgs aur nerd-fonts-terminus powerline-fonts-git nerd-fonts-dejavu-complete nerd-fonts-space-mono
	sudo mkdir -p /usr/local/share/fonts
	# sudo cp -r ~/fonts/* /usr/local/share/fonts
	# sudo fc-cache -f
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
	cat >>~/project_automator/post_run.sh <<EOF
# xrandr
monitor=\$(xrandr | awk '\$2 == "connected"{print \$1}')
sed -i "/xrandr --output eDP1/ s/eDP1/\${monitor}/" ~/.config/i3/config
sed -i "/monitor = \"eDP-1\"/ s/eDP-1/\${monitor}/" ~/.config/polybar/config
# misc
libtool --finish /usr/lib
EOF
	# resolve vsync error in vortual machines
	is_virt="$(systemd-detect-virt)"
	ls ~/.config
	test -z "${is_virt}" || {
		if [[ -f ~/.config/picom.conf ]]; then
			sed -i '/vsync =/ s/./# &/' ~/.config/picom.conf
		elif [[ -f ~/.config/compton.conf ]]; then
			sed -i '/vsync =/ s/./# &/' ~/.config/compton.conf
		fi
	}

	install_pkgs aur st-luke-git
	print_info "${INFO}" "Installing Package libxft-bgra"
	yay -S libxft-bgra --answerdiff N --answerclean A --answeredit N --answerupgrade A --cleanafter --norebuild --noredownload
	[ $? -eq 0 ] && successful_pkgs+=("libxft-bgra") || failed_pkgs+=("libxft-bgra")
	install_pkgs pacman flameshot dunst libnotify
	install_pkgs aur ruby-colorls
	# Dunst
	mkdir ~/.config/dunst
	wget https://raw.githubusercontent.com/dunst-project/dunst/master/dunstrc ~/.config/dunst/dunstrc
	sudo systemctl enable --user dunst.service
	sudo systemctl start --user dunst.service
	# ranger
	install_pkgs pacman ranger atool ffmpegthumbnailer highlight libcaca mediainfo odt2txt poppler poppler-data python-chardet transmission-cli ueberzug w3m
	ranger --copy-config=all
	sed -i "/set preview_images false/ s/false/true/" ~/.config/ranger/rc.conf
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
	sudo git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
	# misc
	install_pkgs pacman openssh gdisk rofi feh jpegexiforient imagemagick python-pip python-pywal nitrogen python2 p7zip lrzip unrar tar rsync bash-completion gnome-keyring
	# polybar
	install_pkgs pacman xorg-fonts-misc
	install_pkgs aur ttf-unifont siji-git polybar
	wlan_interface="$(iw dev | awk '$1=="Interface"{print $2}')"
	test -z "${wlan_interface}" ||
		sudo sed -i "/interface = wlp0s20f3/ s/wlp0s20f3/${wlan_interface}/" ~/.config/polybar/config &&
		sudo sed -i "/modules-right = pulseaudio cpu memory wlan battery/ s/wlan //" ~/.config/polybar/config
	# snap
	install_pkgs aur snapd
	sudo systemctl start snapd
}

create_aliases() {
	cat >>~/.zshrc <<EOF
# ls aliases
alias l='colorls'
alias ls='colorls'
alias la='colorls -A'
alias ld='colorls -d'
alias lad='colorls -Ad'
alias lf='colorls -f'
alias laf='colorls -Af'
alias ll='colorls -l'
alias lla='colorls -lA'
alias lr='colorls --report'
alias lt='colorls --tree'

# git aliases
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias go='git checkout'
alias gac='git add . && git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'

# misc
alias du='du -h'

EOF
}

install_ricing() {
	divider "START: Ricing Installation"
	install_pkgs pacman dos2unix picom
	git clone https://github.com/basantech89/arch-ricing ~/arch-ricing
	cd ~/arch-ricing || exit "${DIR_NOT_EXISTS}"
	find . -type f -not -path '*/\.git/*' ! -name '*.jpg' -print0 | xargs -0 dos2unix -f
	sudo rm -rf .git
	sudo rm -f .gitignore
	sudo rm -f .gitconfig
	cd .. || exit "${HOME_DIR_NOT_EXIST}"
	sudo cp -r ~/arch-ricing/. ~/
	install_oh_my_zsh
	install_fonts
	install_tools
	create_aliases
	sudo chown -R "${USER}" /home/"${USER}/"
	sudo chmod u+rwx -R /home/"${USER}/"
	rm -rf ~/arch-ricing
	divider "END: Ricing Installation"
} > >(tee -i ~/project_automator/installation_ricing.log) 2> >(tee -i ~/project_automator/installation_error_ricing.log >&2)
