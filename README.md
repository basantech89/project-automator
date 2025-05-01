# Project Automator

Automator automates environment setup. Automator assumes you don't have even git installed, and then install the tools like git, node, dbeaver, postman, warp terminal, etc. It'll skip the installation of tools if they are already installed.

You can run this tool as many times as you want, and choose different options as per your choice.

## Tools

it install below tools for you

- git, sudo, curl, wget, gpg, jq, xclip, cowsay, lolcat
- neovim, warp terminal, starship, nvm, node, google chrome, dbeaver, postman, docker, aws cli
- ncdu, peco, safe-rm, plocate, highlight, ripgrep, colorls, app image launcher, zoxide, fortune
- Fonts: CaskaydiaMono, Terminess, ComicShanns, Maple Mono

If your package manager is pacman

- It install paru as well for you.

If your package manager is apt-get and if you chose zsh

- It set your terminal font to ComicShans nerd font since nerd font support ligatures which are needed for the powerlevel10k theme that Automator installs.

## SHELL

You can choose among bash, zsh, or fish. Automator adds command not found script to your shell so if you type a wrong command, it'll mock you in a funny way.

I'd recommend to choose the fish shell as your shell program.

- If you choose fish
  - It install fisher and below fisher plugins.
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
  - [git](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git)
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
  - [docker](https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/docker)

You can find all the plugins, their aliases, and description that Automator install for zsh here <https://github.com/ohmyzsh/ohmyzsh/wiki/plugins>

## Aliases

Automator add below aliases -

- sc: source your shell config
- ls: colrols
- la: colorls -a
- lla: colorls -la
- pman: sudo pacman -Syu --needed --noconfirm (if you package manager is pacman)
- pu: paru -Syu --removemake --cleanafter --needed --noconfirm (if you package manager is pacman)
- z: zoxide for easy directory navigation
- plugins added for oh-my-zsh or fisher adds their aliases, e.g docker plugin add its aliases

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

## Issues

Feel free to raise the issues, request new features or contribute to the project.

## ToDo

1. Test the project on MacOS
2. Replace GNU stow with chezmoi
