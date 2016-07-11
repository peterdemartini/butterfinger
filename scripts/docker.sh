#!/bin/bash

check_daemon() {
  echo '* checking daemon'
  docker ps | grep 'Cannot connect to the Docker daemon'
}

remove_docker() {
  echo '* removing docker'
  sudo apt-get remove --auto-remove docker
}

move_service_and_add_flags() {
  echo '* move service and add mounting flags'
  local form_path='/lib/systemd/system/docker.service'
  local to_path='/etc/systemd/system/docker.service'
  sudo cat "$form_path" | \
    sed -e 's/MountFlags=slave/#MountFlags=slave/' | \
    sudo tee "$to_path" > /dev/null
}

reload_daemon() {
  echo '* reloading daemon'
  sudo systemctl daemon-reload && \
    sudo systemctl restart docker.service
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
  local base_uri='https://github.com/docker/compose/releases/download/1.6.2'
  if [ -z "$(which docker-compose)" ]; then
    echo '* download docker composer'
    sudo curl -sSL "$base_uri/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
  else
    echo '* docker compose already installed'
  fi
}

setup_compose() {
  echo '* setup compose'
  sudo chmod +x /usr/local/bin/docker-compose
}

main() {
  echo '* running docker.sh...'

  setup && \
    install_docker && \
    grant_permissions && \
    move_service_and_add_flags && \
    reload_daemon && \
    download_compose && \
    setup_compose && \
    echo "* done." && \
    exit 0

  echo '* failed to run docker.sh'
  exit 1
}

main "$@"
