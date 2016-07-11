#!/bin/bash

download_and_source_base() {
  echo '* downloading base.sh'
  local file_path='/tmp/butterfinger-scripts/base.sh'
  curl -ssL "https://raw.githubusercontent.com/peterdemartini/butterfinger/master/scripts/base.sh?r=${RANDOM}" -o "$file_path"
  source "$file_path"
}

create_scripts_dir() {
  echo "* creating butterfinger-scripts dir"
  rm -rf "$SCRIPTS_DIR"
  mkdir -p "$SCRIPTS_DIR"
}

create_directories() {
  echo '* creating directories'
  create_dir "$SERVICES_DIR"
  create_dir "$PLEX_CONFIG_DIR"
  create_dir "$PLEX_CONFIG_DIR/plex"
  create_dir "$PLEX_CONFIG_DIR/acd-cli"
  create_dir "$CONFIG_DIR"
  create_shared_dir "$PLEX_DATA_DIR"
  if [ ! -d "$PROJECTS_DIR" ]; then
    create_dir "$PROJECTS_DIR"
  fi
}

run_script() {
  local script="$1"
  echo "* running script $script"
  local file_path="${SCRIPTS_DIR}/${script}"
  "$file_path"
}

copy_butterfinger_config() {
  echo '* copying butterfinger config'
  mv /home/butterfinger/config/* "$CONFIG_DIR"
}

make_butterfinger_tmp() {
  echo '* making butterfinger tmp'
  mkdir -p /tmp/butterfinger-scripts
}

main() {
  echo "* running init.sh..."
  sudo touch /tmp/.enable-sudo-at-first && \
    make_butterfinger_tmp && \
    download_and_source_base && \
    create_scripts_dir && \
    create_directories && \
    copy_butterfinger_config && \
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
