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

main() {
  echo '* running init-docker.sh...'

  setup && \
    install_docker && \
    grant_permissions && \
    echo "* done." && \
    exit 0

  echo '* failed to run init-docker.sh'
  exit 1
}

main "$@"
