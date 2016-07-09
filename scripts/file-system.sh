#!/bin/bash

if [ -z "$BASE_DIR" ]; then
  source '/tmp/butterfinger-scripts/base.sh'
fi

BUTTERFINGER_DOCKER_DIR="$PROJECTS_DIR/butterfinger-docker"

download_butterfinger_docker(){
  if [ -d "$BUTTERFINGER_DOCKER_DIR" ]; then
    echo '* updating butterfinger_docker'
    pushd "$BUTTERFINGER_DOCKER_DIR"
      git pull || return 1
    popd
  else
    echo '* download butterfinger_docker'
    git clone https://github.com/peterdemartini/butterfinger-docker.git "$BUTTERFINGER_DOCKER_DIR" || return 1
  fi
}

main() {
  echo '* running file-system.sh...'
  download_butterfinger_docker && \
    echo '* done.' && \
    exit 0
}

main "$@"
