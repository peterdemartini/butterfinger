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
  echo '* docker compose up'
  pushd "$BUTTERFINGER_DOCKER_DIR" > /dev/null
    env ENCFS_PASS="$BUTTERFINGER_PASSWORD" docker-compose up -d
  popd > /dev/null
}

copy_oauth_data() {
  local oauth_data_path='/home/butterfinger/secrets/oauth_data'
  if [ -f "$oauth_data_path" ]; then
    echo '* moving oauth_data secrets'
    create_dir "$PLEX_DATA_DIR/acd_cli"
    sudo mv "$oauth_data_path" "$PLEX_DATA_DIR/acd_cli/oauth_data"
  fi
}

create_shared_dir() {
  echo '* creating shared directory'
  sudo mount --bind "$PLEX_DATA_DIR" "$PLEX_DATA_DIR" && \
    sudo mount --make-shared "$PLEX_DATA_DIR" && \
    findmnt -o TARGET,PROPAGATION "$PLEX_DATA_DIR"
}

main() {
  echo '* running file-system.sh...'
  create_shared_dir && \
    download_butterfinger_docker && \
    compose_it && \
    copy_oauth_data && \
    echo '* done.' && \
    exit 0
}

main "$@"
