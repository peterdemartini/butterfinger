#!/bin/bash

apt_update() {
  echo "* apt-get update"
  sudo apt-get update
}

install_git() {
  echo "* installing git"
  sudo apt-get install git
}

main() {
  echo "* running init-server.sh..."
  apt_update || exit 1
  install_git || exit 1
  echo "* done."
}

main "$@"