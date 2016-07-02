#!/bin/bash

download_and_source_base() {
  curl -ssL "https://raw.githubusercontent.com/peterdemartini/butterfinger/master/scripts/base.sh?r=${RANDOM}" | source
}

create_scripts_dir() {
  echo "* creating butterfinger-scripts dir"
  rm -rf "$SCRIPTS_DIR"
  mkdir -p "$SCRIPTS_DIR"
}

create_directories() {
  echo '* creating directories'
  sudo mkdir -p "$BASE_DIR"
  sudo mkdir -p "$PROJECTS_DIR"
  sudo mkdir -p "$PLEX_CONFIG_DIR"
  sudo mkdir -p "$PLEX_DATA_DIR/.local-secure"
  sudo mkdir -p "$PLEX_DATA_DIR/local-data"
  sudo mkdir -p "$PLEX_DATA_DIR/.b2-secure"
  sudo mkdir -p "$PLEX_DATA_DIR/b2-data"
  sudo mkdir -p "$(dirname "$PLEX_ENV_FILE")"
  sudo mkdir -p "$SERVICES_DIR"
  sudo chmod -R 0775 "$BASE_DIR"
  sudo chgrp -R butterfinger "$BASE_DIR"
}

run_script() {
  local script="$1"
  echo "* running script $script"
  local file_path="${SCRIPTS_DIR}/${script}"
  "$file_path"
}

main() {
  echo "* running init.sh..."
  sudo touch /tmp/.enable-sudo-at-first && \
    download_and_source_base && \
    create_scripts_dir && \
    create_directories && \
    download_script 'server.sh' && \
    download_script 'docker.sh' && \
    download_script 'file-system.sh' && \
    download_script 'plex.sh' && \
    run_script 'server.sh' && \
    run_script 'docker.sh' && \
    run_script 'file-system.sh' && \
    run_script "plex.sh" && \
    echo '* done with init.sh' && \
    exit 0

  echo "* failed to run init.sh"
  exit 1
}

main "$@"
