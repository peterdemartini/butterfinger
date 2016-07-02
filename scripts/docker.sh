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
  echo '* installing docker'
  curl -sSL https://get.docker.com/ | sh
}

grant_permissions() {
  echo '* granting permissions'
  sudo usermod -aG docker "$(whoami)"
}

main() {
  echo '* running init-docker.sh...'
  if [ ! -z "$(which docker)" ]; then
    echo '* docker already installed'
    check_daemon
    if [ "$?" != "0" ]; then
      echo '* cannot connector docker daemon'
      remove_docker
    else
      echo '* done.'
      exit 0
    fi
  fi

  setup && \
    install_docker && \
    grant_permissions && \
    echo "* done." && \
    exit 0

  echo '* failed to run init-docker.sh'
  exit 1
}

main "$@"
