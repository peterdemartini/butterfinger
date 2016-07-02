#!/bin/bash

SCRIPTS_DIR='/tmp/butterfinger-scripts'

create_scripts_dir() {
  echo "* creating butterfinger-scripts dir"
  rm -rf "$SCRIPTS_DIR"
  mkdir -p "$SCRIPTS_DIR"
}

download_script() {
  local script="$1"
  local repo="https://raw.githubusercontent.com/peterdemartini/butterfinger"
  local file_path="${SCRIPTS_DIR}/${script}"
  echo "* downloading $script"
  rm "$file_path" &> /dev/null
  curl -sSL "${repo}/master/scripts/${script}" -o "$file_path" || exit 1
  chmod +x "$file_path"
}

run_script() {
  local script="$1"
  echo "* running script $script"
  local file_path="${SCRIPTS_DIR}/${script}"
  "$file_path" || exit 1
}

main() {
  echo "* starting butterfinger setup"
  sudo touch /tmp/.enable-sudo-at-first && \
    create_scripts_dir && \
    download_script "server.sh" && \
    download_script "docker.sh" && \
    download_script "plex.sh" && \
    run_script "server.sh" && \
    run_script "docker.sh" && \
    run_script "plex.sh" && \
    echo "* butterfinger setup done!" && \
    exit 0

  echo "* failed to run init.sh"
  exit 1
}

main "$@"
