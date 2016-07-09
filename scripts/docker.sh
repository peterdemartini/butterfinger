#!/bin/bash

check_daemon() {
  echo '* checking daemon'
  docker ps | grep 'Cannot connect to the Docker daemon'
}

remove_docker() {
  echo '* removing docker'
  sudo apt-get remove --auto-remove docker
}

setup() {
  if [ -z "$(which dmsetup)" ]; then
    echo '* installing dmsetup'
    sudo apt-get install dmsetup -y
    sudo dmsetup mknodes
  fi
}

install_docker() {
  if [ ! -z "$(which docker)" ]; then
    echo '* docker already installed'
    return 0
  fi
  echo '* installing docker'
  curl -sSL https://get.docker.com/ | sh
}

grant_permissions() {
  echo '* granting permissions'
  sudo usermod -aG docker "$(whoami)"
}

download_compose() {
  echo '* download docker composer'
  local base_uri='https://github.com/docker/compose/releases/download/1.6.2'
  curl -L "$base_uri/docker-compose-$(uname -s)-$(uname -m)" \
    > /usr/local/bin/docker-compose
}

setup_compose() {
  echo '* setup compose'
  chmod +x /usr/local/bin/docker-compose
}

main() {
  echo '* running docker.sh...'

  setup && \
    install_docker && \
    grant_permissions && \
    download_compose && \
    setup_compose && \
    echo "* done." && \
    exit 0

  echo '* failed to run docker.sh'
  exit 1
}

main "$@"
