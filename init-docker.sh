#!/bin/bash

apt_update() {
  echo "* apt-get update"
  sudo apt-get update
}

install_docker_deps() {
  echo "* install docker deps"
  sudo apt-get install apt-transport-https ca-certificates
}

add_key() {
  echo "* add docker apt-key"
  sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
}

add_to_sources() {
  echo "* add docker to sources"
  echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
}

update_policy() {
  echo "* add docker-engine policy"
  apt-cache policy docker-engine
}

install_docker() {
  echo "* installing docker-engine"
  sudo apt-get install -y docker-engine
}

main() {
  echo "* running init-docker.sh..."
  apt_update || exit 1
  install_docker_deps || exit 1
  add_key || exit 1
  add_to_sources || exit 1
  apt_update || exit 1
  update_policy || exit 1
  install_docker || exit 1
  echo "* done"
}

main "$@"
