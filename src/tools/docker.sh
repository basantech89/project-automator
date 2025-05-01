#!/usr/bin/env bash

install_docker() {
  if ! is_pkg_installed docker; then
    if [ "$package_manager" = 'pacman' ]; then
      echo "$SUDO_PASSWORD" | sudo -S tee /etc/modules-load.d/loop.conf <<<"loop" # enable the loop module
      modprobe loop
      # parallel gzip compressor support
      install_pkgs docker docker-compose pigz
    elif test $package_manager = apt-get; then
      retry_if_failed curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
      add_apt_repo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
      install_pkgs docker-ce pigz
    elif [ "$package_manager" = 'brew' ]; then
      install_pkgs --cask docker
      install_pkgs pigz
      install_pkgs docker-compose
    fi

    [ $? -eq 0 ] && {
      successful_pkgs+=('docker')
      echo "$SUDO_PASSWORD" | sudo -S systemctl start docker
      echo "$SUDO_PASSWORD" | sudo -S systemctl enable docker
      echo "$SUDO_PASSWORD" | sudo -S groupadd docker
      echo "$SUDO_PASSWORD" | sudo -S usermod -aG docker ${USER}
      echo "$SUDO_PASSWORD" | sudo -S chmod 666 /var/run/docker.sock

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

        if ! grep -q docker ~/.zshrc; then
          sed -i -z -e 's/plugins=(\n\tgit/plugins=(\n\tgit\n\tdocker/' ~/.zshrc
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
    } || failed_pkgs+=('docker')
  fi
}
