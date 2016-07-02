#!/bin/bash

apt_update() {
  echo "* apt-get update"
  sudo apt-get update -y
}

install_git() {
  echo "* installing git"
  sudo apt-get install -y git
}

main() {
  echo "* running init-server.sh..."
  apt_update && \
    install_git && \
    echo "* done." && \
    exit 0

  echo "* failed to run init-server.sh"
  exit 1
}

main "$@"
