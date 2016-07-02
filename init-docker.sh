#!/bin/bash

apt_update() {
  echo "* apt-get update"
  sudo apt-get update -y
}

install_docker_deps() {
  echo "* install docker deps"
  sudo apt-get install -y apt-transport-https ca-certificates
}

add_key() {
  echo "* add docker apt-key"
  sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
}

add_to_sources() {
  echo "* add docker to sources"
  local value="deb https://apt.dockerproject.org/repo ubuntu-xenial main"
  local file="/etc/apt/sources.list.d/docker.list"
  (cat "$file" | grep "$value") && \
    (echo "$value" | sudo tee "$file")
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
  apt_update && \
    install_docker_deps && \
    add_key && \
    add_to_sources && \
    apt_update && \
    update_policy && \
    install_docker && \
    echo "* done." && \
    exit 0

  echo "* failed to run init-docker.sh"
  exit 1
}

main "$@"
