#!/usr/bin/env bash

install_shell_zsh() {
  install_pkgs zsh

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k

  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  sed -i "/ZSH_THEME=\"robbyrussell\"/ s/robbyrussell/powerlevel10k\/powerlevel10k/" ~/.zshrc

  sed -i "/plugins=(git)/ a\\\tgit\n\thistory\n\thistory-substring-search\n\tcolored-man-pages\n\tzsh-autosuggestions\n\tzsh-syntax-highlighting\n\tzsh-completions\n\tcopyfile\n\tcopypath\n\tcopybuffer\n\tz\n\tgitignore\n\tnpm\n\tsudo\n\tsystemadmin\n\tyarn\n\tweb-search\n\tssh\n\turltools\n)" ~/.zshrc
  sed -i "/plugins=(git)/ s/git)//" ~/.zshrc
}

install_shell_fish() {
  if test $package_manager = apt-get; then
    add_apt_repo ppa:fish-shell/release-3
  fi

  install_pkgs fish fzf bat

  # fd is a find alternative, bat support syntax highlighting for programming languages
  test $package_manager = apt-get && install_pkgs fd-find || install_pkgs fd

  fish -c "test $(fisher -v >/dev/null 2>&1) && echo fisher is already installed. || begin
  curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
  fisher install jorgebucaran/fisher
  fisher install markcial/upto
  fisher install jethrokuan/z
  fisher install meaningful-ooo/sponge # keeps ur shell history clean from typos
  fisher install jorgebucaran/autopair.fish
  fisher install nickeb96/puffer-fish # .....
  fisher install acomagu/fish-async-prompt
  fisher install gazorby/fish-abbreviation-tips # show abbreviation tips
  fisher install jhillyerd/plugin-git
  fisher install berk-karaal/loadenv.fish
  fisher install PatrickF1/fzf.fish
  end"
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
