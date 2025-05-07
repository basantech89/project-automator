# Project Automator

Automator automates environment setup. Automator assumes you don't have even git installed, and then install the tools like git, node, dbeaver, postman, warp terminal, etc. It'll skip the installation of tools if they are already installed.

You can run this tool as many times as you want, and choose different options as per your choice.

## SHELL

You can choose among bash, zsh, or fish. I'd recommend to choose the fish shell as your shell program.

- if you choose to use zsh shell
- zsh: The shell itself
- [oh-my-zsh](https://ohmyz.sh/)
- Terminal theme: [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Plugins](https://github.com/ohmyzsh/ohmyzsh/wiki/plugins):
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
  - sudo
  - systemadmin
  - web-search
  - ssh
  - urltools
  - if you choose to install node
    - npm
    - yarn
- If you choose to use fish shell
  - fish: The shell itself
  - fzf: The Fuzzy Finder
  - bat
  - fd
  - [fisher](https://github.com/jorgebucaran/fisher): fish shell plugins manager
    - Plugins
      - [markcial/upto](https://github.com/Markcial/upto)
      - [meaningful-ooo/sponge](https://github.com/meaningful-ooo/sponge)
      - [jorgebucaran/autopair.fish](https://github.com/jorgebucaran/autopair.fish)
      - [nickeb96/puffer-fish](https://github.com/nickeb96/puffer-fish)
      - [acomagu/fish-async-prompt](https://github.com/Gazorby/fish-abbreviation-tips)
      - [gazorby/fish-abbreviation-tips](https://github.com/Gazorby/fish-abbreviation-tips)
      - [jhillyerd/plugin-git](https://github.com/jhillyerd/plugin-git)
      - [berk-karaal/loadenv.fish](https://github.com/berk-karaal/loadenv.fish)
      - [PatrickF1/fzf.fish](https://github.com/PatrickF1/fzf.fish)
      - [Alaz-Oz/fish-insulter](https://github.com/Alaz-Oz/fish-insulter)
  - Custom Functions:
    - copyfile: copy the content of a file
    - copypath: copy the current path
    - copyfilepath: copy the path of a file

You can find all the plugins, their aliases, and description that Automator install for zsh here <https://github.com/ohmyzsh/ohmyzsh/wiki/plugins>

## Tools

it install below tools for you

- Installed by Automator automatically
  - [dialog](https://linuxcommand.org/lc3_adv_dialog.php): take user input with a dialog
  - git
  - sudo
  - curl
  - wget
  - gpg
  - [jq](https://jqlang.org/): to process JSON data
  - [xclip](https://linuxconfig.org/how-to-use-xclip-on-linux): to interact with system clipboard
  - vim
  - [cowsay](https://itsfoss.com/cowsay/): show you a cow in the terminal
    - cows: Some cowsay cow files that I handpicked
  - [lolcat](https://github.com/busyloop/lolcat): display text in your terminal with rainbow colors
  - [fortune](https://www.howtogeek.com/linux-terminal-fortune-command/): tell you fortune
  - unzip
  - zip
  - paru: Automator install this aur-helper if your package manager is pacman to install packages from the AUR
  - software-properties-common: if your package manager is apt-get
  - apt-transport-https: if your package manager is apt-get
  - ca-certificates: if your package manager is apt-get
  - bash-completion: if your package manager is apt-get
  - brew: if your package manager is brew
  - bash-completion@2: if your package manager is brew
  - snap: to install snap packages
  - [ncdu](https://www.tecmint.com/ncdu-a-ncurses-based-disk-usage-analyzer-and-tracker/): powerful disk analyzer
  - [peco](https://github.com/peco/peco): interactive filtering
  - [safe-rm](https://github.com/kaelzhang/shell-safe-rm): move files to trash instead of directly deleting
  - [plocate](https://plocate.sesse.net/): find any file in linux
  - [highlight](https://linux.die.net/man/1/source-highlight): colored cat
  - [ripgrep](https://github.com/BurntSushi/ripgrep)
  - [zoxide](https://github.com/ajeetdsouza/zoxide): smarter cd command
  - [colorls](https://github.com/athityakumar/colorls): ls alternative that shows file icons as well
    - ruby
    - If your package manager is apt-get
      - ruby-dev
  - If your package manager is pacman
    - [app image launcher](https://github.com/TheAssassin/AppImageLauncher)
  - [direnv](https://direnv.net/): load environment variables from an .envrc file or an.env file
  - command-not-found script: insulter script that runs when a command is not found

- You choose
  - neovim
    - python3-dev: if your package manager is apt-get
    - python3-pip: if your package manager is apt-get
  - [warp terminal](https://www.warp.dev/)
    - Automator sets below configuration automatically
      - Theme: Cyberwave
      - Font: CaskaydiaCove Nerd Font
      - InputMode: PinnedToTop (so you don't have to turn your neck down all the time, good ergonomically)
  - [starship](https://starship.rs/): if you choose to use fish shell
  - node: install node with [FNM](https://github.com/Schniz/fnm)
  - google chrome
  - dbeaver
    - dbeaver-plugin-office: if your package manager is pacman
  - postman
  - docker
  - aws cli
  - notion
  - microsoft teams
  - slack
  - brave browser
  - vscode

## Fonts

- [Nerd Fonts](https://www.nerdfonts.com/font-downloads): CaskaydiaMono, Terminess, ComicShanns
- Maple Mono

If your package manager is apt-get and if you chose zsh

- It set your terminal font to ComicShans nerd font since nerd font support ligatures which are needed for the Powerlevel10k theme that Automator installs.

## Aliases

Automator add below aliases -

- hcat: highlight -O ansi
- ls: colorls
- la: colorls -a
- ll: colorls -l
- lla: colorls -la
- If your package manager is pacman
  - pman: sudo pacman -Syu --needed --noconfirm
  - pu: paru -Syu --removemake --cleanafter --needed --noconfirm
  - pm: sudo pacman-mirrors --fasttrack 20 && sudo pacman -Syyu
  - pma: sudo pacman-mirrors --country all
- If your package manager is apt-get
  - ag: sudo apt install -y
- If you choose to use fish shell
  - sc: source ~/.config/fish/config.fish
- If you choose to use zsh shell
  - sc: source source ~/.zshrc
- If you choose to use bash shell
  - sc: source ~/.bashrc
- z: zoxide for easy directory navigation, added by zoxide
- plugins added for oh-my-zsh or fisher adds their own aliases, e.g docker plugin add its aliases

## Execution

- Open the terminal
- Clone the repo, use wget as below if you don't have git
  - ```wget https://github.com/basantech89/project-automator/archive/main.zip -O project-automator.zip```
- Unzip the zip file
- Give the app.sh file permission to execute `chmod +x <path-to-the-project>/app.sh`
- Run `<path-to-the-project>/app.sh`

If the script fails, run it again, it'll pass unless there's a fatal issue.

## Logs

Project automator store its logs in the `<path-to-the-project>/main.log`, and `<path-to-the-project>/main-error.log` files, so that you can check what it did at each step.

## Post Installation

Don't forget to logout and login back in, or reboot your system once the script has been executed.

Optionally, run below command if you choose zsh as the shell. I couldn't do it in the script since oh-my-zsh creates problems with it. A cow will greet you with a fortune in a new session every time. It's done already if you choose any other shell.

```sed -i '1s;^;fortune -s | cowsay -f `ls -1 /usr/share/cowsay/cows/*.cow | sort -R | head -1` | lolcat\n;' ~/.zshrc```

## Tests

Although the code is written to run the scripts for Linux(Ubuntu, and Arch Linux), or Mac and for shells fish, zsh, or bash, but the scripts are tested only with Ubuntu 22 with fish and zsh shells. I'll try to test it on other systems as well.

## Showcase

Below is how your terminal will look like in

Ubuntu with zsh shell
![automator-ubuntu-zsh](/images/automator-ubuntu-zsh.png)

Ubuntu with warp terminal with fish shell
![automator-ubuntu-warp-zsh](/images/automator-ubuntu-fish-warp.png)

Ubuntu with neovim
![ubuntu-with-neovim](/images/automator-nvim.png)

Ubutu with the tools
![tools](/images/automator.gif)

## Issues

Feel free to raise the issues, request new features or contribute to the project.

## ToDo

1. Test the project on MacOS
