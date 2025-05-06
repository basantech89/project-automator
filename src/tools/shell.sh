#!/usr/bin/env bash

install_shell_bash() {
  if [ ! -f /etc/bash.command-not-found ]; then
    sudo wget -O /etc/bash.command-not-found https://raw.githubusercontent.com/hkbakke/bash-insulter/master/src/bash.command-not-found
  fi

  if ! grep -q "bash.command-not-found" ~/.bashrc; then
    cat <<EOT >>~/.bashrc

eval "$(stack --bash-completion-script stack)"

if [ -f /etc/bash.command-not-found ]; then
    . /etc/bash.command-not-found
fi
EOT
  fi

  if [ "$package_manager" = 'brew' ]; then
    if ! grep -q "bash_completion" ~/.bashrc; then
      cat >>~/.bashrc <<EOF

[[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
EOF
    fi
  else
    if ! grep -q "bash_completion" ~/.zshrc; then
      cat <<EOT >>~/.bashrc

eval "$(stack --bash-completion-script stack)"

if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
EOT
    fi
  fi
}

install_shell_zsh() {
  install_pkgs zsh

  if [ ! -d ~/.oh-my-zsh ]; then
    retry_if_failed sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  if ! grep -q powerlevel10k ~/.zshrc; then
    retry_if_failed git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

    retry_if_failed git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
    sed -i '/source \$ZSH\/oh-my-zsh.sh/i fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src' ~/.zshrc

    retry_if_failed git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    retry_if_failed git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    sed -i "/ZSH_THEME=\"robbyrussell\"/ s/robbyrussell/powerlevel10k\/powerlevel10k/" ~/.zshrc

    sed -i "/plugins=(git)/ a\\\tgit\n\thistory\n\thistory-substring-search\n\tcolored-man-pages\n\tzsh-autosuggestions\n\tzsh-syntax-highlighting\n\tcopyfile\n\tcopypath\n\tcopybuffer\n\tgitignore\n\tsudo\n\tsystemadmin\n\tweb-search\n\tssh\n\turltools\n)" ~/.zshrc
    sed -i "/plugins=(git)/ s/git)//" ~/.zshrc
  fi

  if [ ! -f /etc/bash.command-not-found ]; then
    retry_if_failed sudo wget -O /etc/bash.command-not-found https://raw.githubusercontent.com/hkbakke/bash-insulter/master/src/bash.command-not-found
  fi

  if ! grep -q "bash.command-not-found" ~/.zshrc; then
    cat <<EOT >>~/.zshrc

if [ -f /etc/bash.command-not-found ]; then
    . /etc/bash.command-not-found
fi
EOT
  fi
}

install_shell_fish() {
  if test $package_manager = apt-get; then
    add_apt_repo ppa:fish-shell/release-3
  fi

  install_pkgs fish fzf bat

  # fd is a find alternative, bat support syntax highlighting for programming languages
  test $package_manager = apt-get && install_pkgs fd-find || install_pkgs fd

  fish -c "if type -q fisher
    echo fisher is already installed.
  else
    begin
      curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
      fisher install jorgebucaran/fisher
      fisher install markcial/upto
      fisher install meaningful-ooo/sponge # keeps ur shell history clean from typos
      fisher install jorgebucaran/autopair.fish
      fisher install nickeb96/puffer-fish # .....
      fisher install acomagu/fish-async-prompt
      fisher install gazorby/fish-abbreviation-tips # show abbreviation tips
      fisher install jhillyerd/plugin-git
      fisher install berk-karaal/loadenv.fish
      fisher install PatrickF1/fzf.fish
      fisher install Alaz-Oz/fish-insulter
    end
  end"

  if ! grep -q "cowsay" ~/.config/fish/conf.d/insulter.fish; then
    echo "$SUDO_PASSWORD" | sudo -S cp *.cow $AUTOMATOR_DIR/src/assets/cows /usr/share/cowsay/cows/
    sed -i -e '/\s\s__insulter_print_message/ i\    set -l toon (random choice {alpaca,bong,bud-frogs,bunny,cower,default,dragon,elephant,eyes,fox,hellokitty,koala,llama,meow,moofasa,moose,mutilated,sheep,skeleton,small,stegosaurus,supermilker,surgery,three-eyes,turtle,tux,udder,vader,www})' ~/.config/fish/conf.d/insulter.fish
    sed -i -e '/\s\s__insulter_print_message/ s/__insulter_print_message/__insulter_print_message | cowthink -f $toon | lolcat/g' ~/.config/fish/conf.d/insulter.fish
  fi

  if ! grep -q "set freq 10" ~/.config/fish/conf.d/insulter.fish; then
    sed -i -e 's/set freq 4/set freq 10/g' ~/.config/fish/conf.d/insulter.fish
  fi

  if [ ! -f ~/.config/fish/config.fish ]; then
    cat >~/.config/fish/config.fish <<EOF
if status is-interactive
  # Commands to run in interactive sessions can go here
end

function copyfile
    xclip -sel c <\$argv
end

function copypath
    pwd | xclip -sel c
end

function copyfilepath
    set -f file \$(pwd)/\$(basename \$argv[1])
    if test -e "\$file"
        echo \$file | xclip -sel c
    else
        echo "file \$argv[1] not found."
    end
end
EOF
  elif ! grep -qw "copyfilepath" ~/.config/fish/config.fish; then
    cat >>~/.config/fish/config.fish <<EOF

function copyfile
    xclip -sel c <\$argv
end

function copypath
    pwd | xclip -sel c
end

function copyfilepath
    set -f file \$(pwd)/\$(basename \$argv[1])
    if test -e "\$file"
        echo \$file | xclip -sel c
    else
        echo "file \$argv[1] not found."
    end
end
EOF
  fi
}

install_shell() {
  local current_shell=$(sh -c 'ps -p $$ -o ppid=' | xargs ps -o comm= -p)

  case $shell in
  bash)
    test $current_shell = "bash" || echo "$SUDO_PASSWORD" | chsh -s $(which bash)
    ;;
  zsh)
    install_shell_zsh
    test $current_shell = "zsh" || echo "$SUDO_PASSWORD" | chsh -s $(which zsh)
    ;;
  fish)
    install_shell_fish
    test $current_shell = "fish" || echo "$SUDO_PASSWORD" | chsh -s /usr/bin/fish
    ;;
  esac
}
