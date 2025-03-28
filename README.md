# Project Automator

Automator automates environment setup

## Tools

it install below tools for you

- git, sudo, curl, wget, gpg, jq, xclip, cowsay, lolcat
- neovim, warp terminal, starship, nvm, node, google chrome, dbeaver, postman, docker, aws cli
- ncdu, peco, safe-rm, plocate, highlight, ripgrep, colorls, app image launcher, zoxide, fortune
- Fonts: CaskaydiaMono, Terminess, ComicShanns, Maple Mono

If your package manager is pacman

- It install paru as well for you.

If your package manager is apt-get

- It set your terminal font to ComicShans

## SHELL

You can choose among bash, zsh, or fish. Automator adds command not found script to your shell so if you type a wrong command, it'll mock you in a funny way.

- If you choose fish
  - It install below fisher and below fisher plugins.
    - markcial/upto
    - meaningful-ooo/sponge
    - jorgebucaran/autopair.fish
    - nickeb96/puffer-fish
    - acomagu/fish-async-prompt
    - gazorby/fish-abbreviation-tips
    - jhillyerd/plugin-git
    - berk-karaal/loadenv.fish
    - PatrickF1/fzf.fish
    - Alaz-Oz/fish-insulter

  - It also adds below functions
    - copyfile: to copy the file content in clipboard
    - copypath: to copy the pwd in clipboard
    - copyfilepath: to copy the path of a file in clipboard

- If you choose zsh, it install oh-my-zsh and the theme powerlevel10k, and adds below plugins
  - git
  - history
  - history-substring-search
  - colored-man-pages
  - zsh-autosuggestions
  - zsh-syntax-highlighting
  - copyfile
  - copypath
  - copybuffer
  - gitignore
  - npm
  - sudo
  - systemadmin
  - yarn
  - web-search
  - ssh
  - urltools

## Aliases

Automator add below aliases -

- sc: source your shell config
- ls: colrols
- la: colorls -a
- lla: colorls -la
- pman: sudo pacman -Syu --needed --noconfirm (if you package manager is pacman)
- pu: paru -Syu --removemake --cleanafter --needed --noconfirm (if you package manager is pacman)
- z: zoxide for easy directory navigation

## Execution

- Clone the repo, use wget as below if you don't have git
  - ```wget https://github.com/basantech89/project-automator/archive/main.zip -O project-automator.zip```
- Open the terminal
- Give the app.sh file permission to execute `chmod +x <path-to-the-zip-file>/app.sh`
- Run `<path-to-the-zip-file>/app.sh`

## Logs

Project automator store its logs in the `<path-to-the-zip-file>/main.log`, and `<path-to-the-zip-file>/main-error.log` files, so that you can check what it did at each step.

## Post Installation

Don't forget to logout and login back in, or reboot your system once the script has been executed.
