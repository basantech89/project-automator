#!/usr/bin/env bash

. ./src/variables.sh

install_oh_my_zsh() {
    cd ~ || exit "${DIR_NOT_EXISTS}"
    sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    sed -i "/ZSH_THEME=\"robbyrussell\"/ s/robbyrussell/powerlevel10k\/powerlevel10k/" ~/.zshrc
    sed -i "/plugins=(git)/ a\\\tarchlinux\n\tgit\n\thistory-substring-search\n\tcolored-man-pages\n\tzsh-autosuggestions\n\tzsh-syntax-highlighting\n)" zshrc
    sed -i "/plugins=(git)/ s/git)//" ~/.zshrc
}

install_ricing() {
    git clone https://github.com/basantech89/arch-ricing ~/arch-ricing
    cd ~/arch-ricing || exit
    cp -r * ../
    install_oh_my_zsh
}
