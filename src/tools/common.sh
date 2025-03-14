#!/usr/bin/env bash

install_neovim() {
  if test $package_manager = apt-get; then
    install_pkgs python3-dev python3-pip
  fi

  if ! is_pkg_installed nvim; then
    if validate_version 0.8.0 neovim; then
      install_pkgs neovim
    else
      curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
      echo "$SUDO_PASSWORD" | sudo -S rm -rf /opt/nvim*
      echo "$SUDO_PASSWORD" | sudo -S tar -C /opt -xzf nvim-linux-x86_64.tar.gz
      rm nvim-linux-x86_64.tar.gz
      add_to_path /opt/nvim-linux-x86_64/bin
    fi

    install_dot neovim
  fi

  abbrs[vim]=nvim
}

install_warp_terminal() {
  if ! is_pkg_installed warp-terminal; then
    if [ "$package_manager" = 'pacman' ]; then
      echo "$SUDO_PASSWORD" | sudo -S tee -a /etc/pacman.conf >/dev/null <<EOF
[warpdotdev]
Server = https://releases.warp.dev/linux/pacman/\$repo/\$arch
EOF
      install_pkgs warp-terminal
    elif [ "$package_manager" = 'apt-get' ]; then
      wget -qO- https://releases.warp.dev/linux/keys/warp.asc | gpg --dearmor >warpdotdev.gpg
      echo "$SUDO_PASSWORD" | sudo -S install -D -o root -g root -m 644 warpdotdev.gpg /etc/apt/keyrings/warpdotdev.gpg
      echo "$SUDO_PASSWORD" | sudo -S sh -c 'echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/warpdotdev.gpg] https://releases.warp.dev/linux/deb stable main" > /etc/apt/sources.list.d/warpdotdev.list'
      rm warpdotdev.gpg

      update_system quiet
      install_pkgs warp-terminal
    elif [ "$package_manager" = 'brew' ]; then
      install_pkgs --cask warp
    fi

    install_dot warp ~/.config/warp-terminal
  fi
}

install_nvm() {
  mark_start "Installing Packages nvm" -t$PACKAGE

  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  if [ $shell = bash ]; then
    cat >>~/.bashrc <<EOF
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
EOF
  fi

  if [ $shell = zsh ]; then
    cat >>~/.zshrc <<EOF
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
EOF
  fi

  if [ $shell = fish ]; then
    fish -c "fisher install jorgebucaran/nvm.fish"
  fi

  [ $? -eq 0 ] && successful_pkgs+=('nvm') || failed_pkgs+=('nvm')
  source_shell_config

  mark_end "Installing Packages nvm" -t$PACKAGE
}

install_node_with_nvm() {
  mark_start "Installing Packages node ${node_version}" -t$PACKAGE

  $shell -c "nvm install ${node_version}"

  if [ $shell = fish ]; then
    fish -c "set --universal nvm_default_version ${node_version}"
  else
    $shell -c "
        nvm alias default ${node_version}
        nvm use default
      "
  fi

  if test $shell = fish; then
    fish -C "npm i -g pnpm yarn nx; exit;"
  else
    $shell -c "npm i -g pnpm yarn nx"
  fi

  [ $? -eq 0 ] && successful_pkgs+=("node") || failed_pkgs+=('node')

  mark_end "Installing Packages node ${node_version}" -t$PACKAGE
}

install_node() {
  if ! is_pkg_installed nvm; then
    install_nvm
    install_node_with_nvm
  elif (($($shell -c "nvm list v${node_version} | grep -ic v${node_version}") != 1)); then
    install_node_with_nvm
  else
    log "${INFO}" "Package node ${node_version} is already installed, not installing again."
    already_installed_pkgs+=("node${node_version}")
  fi
}

install_fonts() {
  install_nerd_fonts -s CaskaydiaMono "CascadiaMono"
}

install_starship() {
  if ! is_pkg_installed starship; then
    mark_start "Install Starship" -t$PACKAGE

    curl -sS https://starship.rs/install.sh | sh -s -- -y
    [ $? -eq 0 ] && successful_pkgs+=('starship') || failed_pkgs+=('starship')

    install_dot starship

    if test $shell = fish; then
      sed -i '$ a\\nstarship init fish | source' ~/.config/fish/config.fish
    elif test $shell = bash; then
      sed -i '$ a\\neval "$(starship init bash)"' ~/.bashrc
    elif test $shell = zsh; then
      sed -i '$ a\\neval "$(starship init zsh)"' ~/.zshrc
    fi

    mark_end "Install Starship" -t$PACKAGE
  fi
}

install_google_chrome() {
  if ! is_pkg_installed google-chrome-stable; then
    if [ "$package_manager" = 'pacman' ]; then
      install_pkgs google-chrome
    elif [ "$package_manager" = 'apt-get' ]; then
      install_dpkg_pkg https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    elif [ "$package_manager" = 'brew' ]; then
      install_pkgs --cask google-chrome
    fi
  fi
}

install_vscode() {
  if ! is_pkg_installed code; then
    if [ "$package_manager" = 'pacman' ]; then
      install_pkgs visual-studio-code-bin
    elif [ "$package_manager" = 'apt-get' ]; then
      wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor >/tmp/packages.microsoft.gpg
      echo "$SUDO_PASSWORD" | sudo -S install -D -o root -g root -m 644 /tmp/packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
      echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
      rm -f /tmp/packages.microsoft.gpg

      update_system quiet
      install_pkgs code
    elif [ "$package_manager" = 'brew' ]; then
      install_pkgs --cask visual-studio-code
    fi

    [ $? -eq 0 ] && successful_pkgs+=('vscode') || failed_pkgs+=('vscode')
  fi
}

install_postman() {
  if ! is_pkg_installed postman; then
    if [ "$package_manager" = 'pacman' ]; then
      install_pkgs postman-bin
    elif [ "$package_manager" = 'apt-get' ]; then
      mark_start "Installing Postman" -t$PACKAGE

      echo "$SUDO_PASSWORD" | sudo -S rm -rf /opt/Postman
      tar -C /tmp/ -xzf <(curl -L https://dl.pstmn.io/download/latest/linux64) && echo "$SUDO_PASSWORD" | sudo -S mv /tmp/Postman /opt/
      echo "$SUDO_PASSWORD" | sudo -S ln -s /opt/Postman/Postman /usr/bin/postman
      echo "$SUDO_PASSWORD" | sudo -S tee -a /usr/share/applications/postman.desktop <<END
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Exec=/opt/Postman/Postman
Icon=/opt/Postman/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
END

      mark_end "Installing Postman" -t$PACKAGE
    elif [ "$package_manager" = 'brew' ]; then
      install_pkgs --cask postman
    fi

    [ $? -eq 0 ] && successful_pkgs+=('postman') || failed_pkgs+=('postman')
  fi
}

install_docker() {
  if ! is_pkg_installed docker; then
    if [ "$package_manager" = 'pacman' ]; then
      echo "$SUDO_PASSWORD" | sudo -S tee /etc/modules-load.d/loop.conf <<<"loop" # enable the loop module
      modprobe loop
      install_pkgs docker docker-compose
    elif [ "$package_manager" = 'apt-get' ]; then
      curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      add_apt_repo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
      install_pkgs docker-ce
    elif [ "$package_manager" = 'brew' ]; then
      install_pkgs --cask docker
      install_pkgs docker-compose
    fi

    [ $? -eq 0 ] && successful_pkgs+=('docker') || failed_pkgs+=('docker')

    echo "$SUDO_PASSWORD" | sudo -S systemctl start docker
    echo "$SUDO_PASSWORD" | sudo -S systemctl enable docker
    echo "$SUDO_PASSWORD" | sudo -S groupadd docker
    echo "$SUDO_PASSWORD" | sudo -S usermod -aG docker ${USER}
  fi

  if test $shell = bash; then
    if [ "$package_manager" = 'apt-get' -o "$package_manager" = 'pacman' ]; then
      if ! grep -q "bash_completion" ~/.bashrc; then
        cat <<EOT >>~/.bashrc
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi
EOT
      fi
    elif [ "$package_manager" = 'brew' ]; then
      if ! grep -q "bash_completion" ~/.bash_profile; then
        cat <<EOT >>~/.bash_profile
[[ -r "\$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
EOT
      fi
    fi

    if [ ! -f ~/.local/share/bash-completion/completions/docker ]; then
      mkdir -p ~/.local/share/bash-completion/completions
      docker completion bash >~/.local/share/bash-completion/completions/docker
    fi
  elif test $shell = zsh; then
    if [ ! -f ~/.oh-my-zsh/completions/_docker ]; then
      mkdir -p ~/.oh-my-zsh/completions
      docker completion zsh >~/.oh-my-zsh/completions/_docker
    fi
  elif test $shell = fish; then
    if [ ! -f ~/.config/fish/completions/docker.fish ]; then
      mkdir -p ~/.config/fish/completions
      docker completion fish >~/.config/fish/completions/docker.fish
    fi

    if [ ! -f ~/.config/fish/conf.d/docker.fish ]; then
      cat >>~/.config/fish/conf.d/docker.fish <<EOF
#!/usr/bin/env fish
#
# Copyright (c) 2020 Rich Lewis and François VANTOMME
# License: MIT

# Adapted from https://github.com/akarzim/zsh-docker-aliases

# Docker
abbr -a dk 'docker'
abbr -a dka 'docker attach'
abbr -a dkb 'docker build'
abbr -a dkd 'docker diff'
abbr -a dkdf 'docker system df'
abbr -a dke 'docker exec'
abbr -a dkei 'docker exec -it'
abbr -a dkh 'docker history'
abbr -a dki 'docker images'
abbr -a dkin 'docker inspect'
abbr -a dkim 'docker import'
abbr -a dkk 'docker kill'
abbr -a dkkh 'docker kill -s HUP'
abbr -a dkl 'docker logs'
abbr -a dkL 'docker logs -f'
abbr -a dkli 'docker login'
abbr -a dklo 'docker logout'
abbr -a dkp 'docker pause'
abbr -a dkP 'docker unpause'
abbr -a dkpl 'docker pull'
abbr -a dkph 'docker push'
abbr -a dkps 'docker ps'
abbr -a dkpsa 'docker ps -a'
abbr -a dkr 'docker run'
abbr -a dkri 'docker run -it --rm'
abbr -a dkrie 'docker run -it --rm --entrypoint /bin/bash'
abbr -a dkRM 'docker system prune'
abbr -a dkrm 'docker rm'
abbr -a dkrmi 'docker rmi'
abbr -a dkrn 'docker rename'
abbr -a dks 'docker start'
abbr -a dkS 'docker restart'
abbr -a dkss 'docker stats'
abbr -a dksv 'docker save'
abbr -a dkt 'docker tag'
abbr -a dktop 'docker top'
abbr -a dkup 'docker update'
abbr -a dkv 'docker version'
abbr -a dkw 'docker wait'
abbr -a dkx 'docker stop'
abbr -a dkstop 'docker stop (docker ps -aq)'

# Docker Compose (c)
abbr -a dkc 'docker compose'
abbr -a dkcb 'docker compose build'
abbr -a dkcB 'docker compose build --no-cache'
abbr -a dkcd 'docker compose down'
abbr -a dkce 'docker compose exec'
abbr -a dkck 'docker compose kill'
abbr -a dkcl 'docker compose logs'
abbr -a dkcL 'docker compose logs -f'
abbr -a dkcls 'docker compose ps'
abbr -a dkcp 'docker compose pause'
abbr -a dkcP 'docker compose unpause'
abbr -a dkcpl 'docker compose pull'
abbr -a dkcph 'docker compose push'
abbr -a dkcps 'docker compose ps'
abbr -a dkcr 'docker compose run'
abbr -a dkcR 'docker compose run --rm'
abbr -a dkcrm 'docker compose rm'
abbr -a dkcs 'docker compose start'
abbr -a dkcsc 'docker compose scale'
abbr -a dkcS 'docker compose restart'
abbr -a dkcu 'docker compose up'
abbr -a dkcU 'docker compose up -d'
abbr -a dkcv 'docker compose version'
abbr -a dkcx 'docker compose stop'
#
## Container (C)
abbr -a dkC 'docker container'
abbr -a dkCa 'docker container attach'
abbr -a dkCcp 'docker container cp'
abbr -a dkCd 'docker container diff'
abbr -a dkCe 'docker container exec'
abbr -a dkCei 'docker container exec -it'
abbr -a dkCin 'docker container inspect'
abbr -a dkCk 'docker container kill'
abbr -a dkCl 'docker container logs'
abbr -a dkCL 'docker container logs -f'
abbr -a dkCls 'docker container ls'
abbr -a dkCp 'docker container pause'
abbr -a dkCpr 'docker container prune'
abbr -a dkCrn 'docker container rename'
abbr -a dkCS 'docker container restart'
abbr -a dkCrm 'docker container rm'
abbr -a dkCr 'docker container run'
abbr -a dkCri 'docker container run -it --rm'
abbr -a dkCrie 'docker container run -it --rm --entrypoint /bin/bash'
abbr -a dkCs 'docker container start'
abbr -a dkCss 'docker container stats'
abbr -a dkCx 'docker container stop'
abbr -a dkCtop 'docker container top'
abbr -a dkCP 'docker container unpause'
abbr -a dkCup 'docker container update'
abbr -a dkCw 'docker container wait'

## Image (I)
abbr -a dkI 'docker image'
abbr -a dkIb 'docker image build'
abbr -a dkIh 'docker image history'
abbr -a dkIim 'docker image import'
abbr -a dkIin 'docker image inspect'
abbr -a dkIls 'docker image ls'
abbr -a dkIpr 'docker image prune'
abbr -a dkIpl 'docker image pull'
abbr -a dkIph 'docker image push'
abbr -a dkIrm 'docker image rm'
abbr -a dkIsv 'docker image save'
abbr -a dkIt 'docker image tag'

## Volume (V)
abbr -a dkV 'docker volume'
abbr -a dkVin 'docker volume inspect'
abbr -a dkVls 'docker volume ls'
abbr -a dkVpr 'docker volume prune'
abbr -a dkVrm 'docker volume rm'

## Network (N)
abbr -a dkN 'docker network'
abbr -a dkNs 'docker network connect'
abbr -a dkNx 'docker network disconnect'
abbr -a dkNin 'docker network inspect'
abbr -a dkNls 'docker network ls'
abbr -a dkNpr 'docker network prune'
abbr -a dkNrm 'docker network rm'

## System (Y)
abbr -a dkY 'docker system'
abbr -a dkYdf 'docker system df'
abbr -a dkYpr 'docker system prune'

## Stack (K)
abbr -a dkK 'docker stack'
abbr -a dkKls 'docker stack ls'
abbr -a dkKps 'docker stack ps'
abbr -a dkKrm 'docker stack rm'

## Swarm (W)
abbr -a dkW 'docker swarm'

# Docker Machine (m)
abbr -a dkm 'docker-machine'
abbr -a dkma 'docker-machine active'
abbr -a dkmcp 'docker-machine scp'
abbr -a dkmin 'docker-machine inspect'
abbr -a dkmip 'docker-machine ip'
abbr -a dkmk 'docker-machine kill'
abbr -a dkmls 'docker-machine ls'
abbr -a dkmpr 'docker-machine provision'
abbr -a dkmps 'docker-machine ps'
abbr -a dkmrg 'docker-machine regenerate-certs'
abbr -a dkmrm 'docker-machine rm'
abbr -a dkms 'docker-machine start'
abbr -a dkmsh 'docker-machine ssh'
abbr -a dkmst 'docker-machine status'
abbr -a dkmS 'docker-machine restart'
abbr -a dkmu 'docker-machine url'
abbr -a dkmup 'docker-machine upgrade'
abbr -a dkmv 'docker-machine version'
abbr -a dkmx 'docker-machine stop'

## CleanUp (rm)
# Clean up exited containers (docker < 1.13)
abbr -a dkrmC 'docker rm (docker ps -qaf status=exited)'

# Clean up dangling images (docker < 1.13)
abbr -a dkrmI 'docker rmi (docker images -qf dangling=true)'

# Pull all tagged images
abbr -a dkplI 'docker images --format "{{ .Repository }}" | grep -v "^<none>$" | xargs -L1 docker pull'

# Clean up dangling volumes (docker < 1.13)
abbr -a dkrmV 'docker volume rm (docker volume ls -qf dangling=true)'

# Custom
# Stop and Remove all containers
abbr -a drmf 'docker stop (docker ps -a -q); docker rm (docker ps -a -q)'

# Remove exited containers:
abbr -a drxc 'docker ps --filter status=dead --filter status=exited -aq | xargs docker rm -v'

# Remove unused images:
abbr -a drui 'docker images --no-trunc | grep \'<none>\' | awk \'{ print $3 }\' | xargs docker rmi'

function dbash -d "bash into running container"
  docker exec -it (docker ps -aqf "name=$argv[1]") bash
end
EOF
    fi
  fi
}

install_dbeaver() {
  if ! is_pkg_installed dbeaver; then
    if [ "$package_manager" = 'pacman' ]; then
      wget -qO- https://dbeaver.io/files/dbeaver-ce-latest-linux.gtk.x86_64.tar.gz | gunzip | tar xvf - -C /opt/dbeaver
      echo "$SUDO_PASSWORD" | sudo -S ln -s /opt/dbeaver/dbeaver /usr/bin/dbeaver
      [ $? -eq 0 ] && successful_pkgs+=('dbeaver') || failed_pkgs+=('dbeaver')

    elif [ "$package_manager" = 'apt-get' ]; then
      install_dpkg_pkg https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb
    elif [ "$package_manager" = 'brew' ]; then
      install_pkgs --cask dbeaver-community
    fi
  fi
}

install_aws_cli() {
  if ! is_pkg_installed aws; then
    if [ "$package_manager" = 'pacman' ]; then
      install_pkgs aws-cli-v2
    elif [ "$package_manager" = 'apt-get' ]; then
      install_pkgs --snap --classic aws-cli
    elif [ "$package_manager" = 'brew' ]; then
      install_pkgs awscli
    fi
  fi

  if test $shell = 'fish'; then
    fish -C "complete --command aws --no-files --arguments '(begin; set --local --export COMP_SHELL fish; set --local --export COMP_LINE (commandline); aws_completer | sed \'s/ $//\'; end)';exit"

    if [ ! -f ~/.config/fish/functions/aws.fish ]; then
      cat >~/.config/fish/functions/aws.fish <<EOF
function aws_checks
    if test -z \$AWS_PROFILE
        echo "AWS_PROFILE is not set."
        return 1
    end

    if test "\$AWS_PROFILE" != bp-dev -a "\$AWS_PROFILE" != bp-qa
        echo "AWS_PROFILE is neither bp-dev or bp-qa."
        return 1
    end

    if test (count \$argv) -ne 1
        echo "Expected 1 arguments, got \$(count \$argv)"
        return 1
    end
end

function aws_env_check
    set -g env \$argv[1]

    if test "\$env" != dev -a "\$env" != qa
        echo "Not allowed to get password for \$env environment."
        return 1
    end

    if test "\$env" = dev
        set -g PROFILE bp-dev
    else if test "\$env" = qa
        set -g PROFILE bp-qa
    end
end

function dbpass
    aws_checks "\$argv"
    aws_env_check "\$argv"

    if test \$status -ne 0
        return 1
    end

    set -f secret_name \$(aws secretsmanager list-secrets --profile $PROFILE --output json | jq --arg env "\$env" '.SecretList[].Name | select(contains(\$env)) | select(contains("portal"))')
    set -f secret_string \$(aws secretsmanager get-secret-value --secret-id \$(string sub -s 2 -e -1 \$secret_name) --profile \$PROFILE | jq -r '.SecretString' | jq '.')
    echo \$secret_string | jq '.'
    echo \$secret_string | jq '.password' | string sub -s 2 -e -1 | xclip -sel c
end

function ec2ip
    aws_checks "\$argv"

    if test \$status -ne 0
        return 1
    end

    set -f ip \$(aws ec2 describe-instances | jq '.Reservations[].Instances[] | select(.Tags[].Value | contains("rds-berrybox-portal-ec2")) | .NetworkInterfaces[].Association.PublicIp' | string sub -s 2 -e -1)
    echo \$ip
    echo \$ip | xclip -sel c
end

function ssm
    aws_checks "\$argv"

    if test \$status -ne 0
        return 1
    end

    set -f name \$(aws ssm describe-parameters --parameter-filters "Key=Name,Option=Contains,Values=\$argv[1]" --query 'Parameters | [0].Name' | string sub -s 2 -e -1)
    set -f value \$(aws ssm get-parameter --name "\$name" --with-decryption --query 'Parameter.Value' | string sub -s 2 -e -1)
    echo \$value
    echo \$value | xclip -sel c
end
EOF
    fi
  fi
}
