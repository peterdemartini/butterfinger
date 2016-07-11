#!/bin/bash

if [ -z "$BASE_DIR" ]; then
  source '/tmp/butterfinger-scripts/base.sh'
fi

BUTTERFINGER_DOCKER_DIR="$PROJECTS_DIR/butterfinger-docker"

download_butterfinger_docker(){
  if [ -d "$BUTTERFINGER_DOCKER_DIR" ]; then
    echo '* updating butterfinger_docker'
    pushd "$BUTTERFINGER_DOCKER_DIR" > /dev/null
      git pull > /dev/null || return 1
    popd > /dev/null
  else
    echo '* download butterfinger_docker'
    git clone https://github.com/peterdemartini/butterfinger-docker.git "$BUTTERFINGER_DOCKER_DIR" || return 1
  fi
}

compose_it() {
  echo '* docker compose it'
  pushd "$BUTTERFINGER_DOCKER_DIR" > /dev/null
    docker-compose stop
    docker-compose rm --force
    docker-compose build && \
      env ENCFS_PASS="$BUTTERFINGER_PASSWORD" docker-compose up -d
  popd > /dev/null
}

copy_oauth_data() {
  local oauth_data_path='/home/butterfinger/secrets/oauth_data'
  local to_path="$PLEX_CONFIG_DIR/acd-cli/oauth_data"
  if [ -f "$oauth_data_path" ]; then
    echo '* moving oauth_data secrets'
    rm "$to_path"
    cp "$oauth_data_path" "$to_path"
  fi
}

is_shared() {
  findmnt -o TARGET,PROPAGATION "$PLEX_DATA_DIR" | grep "$PLEX_DATA_DIR"
}

create_shared_dir() {
  echo '* creating shared directory'
  is_shared && return 0
  sudo mount --bind "$PLEX_DATA_DIR" "$PLEX_DATA_DIR" && \
    sudo mount --make-shared "$PLEX_DATA_DIR"
}

main() {
  echo '* running file-system.sh...'
  create_shared_dir && \
    copy_oauth_data && \
    download_butterfinger_docker && \
    compose_it && \
    echo '* done.' && \
    exit 0
}

main "$@"
