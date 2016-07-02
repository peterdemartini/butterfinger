#!/bin/bash

SCRIPTS_DIR='/tmp/butterfinger-scripts'

create_scripts_dir() {
  echo "* creating butterfinger-scripts dir"
  rm -rf "$SCRIPTS_DIR"
  mkdir -p "$SCRIPTS_DIR"
}

download_script() {
  echo "* downloading"
  local script="$1"
  local repo="https://raw.githubusercontent.com/peterdemartini/butterfinger"
  local file_path="${SCRIPTS_DIR}/${script}"
  rm "$file_path" &> /dev/null
  curl -fsS "${repo}/master/${script}" -o "$file_path" || exit 1
  chmod +x "$file_path"
}

run_script() {
  echo "* running script"
  local script="$1"
  local file_path="${SCRIPTS_DIR}/${script}"
  "$file_path" || exit 1
}

main() {
  echo "* starting butterfinger setup"
  sudo touch /tmp/.enable-sudo-at-first && \
    create_scripts_dir && \
    download_script "init-server.sh" && \
    download_script "init-docker.sh" && \
    download_script "init-plex.sh" && \
    run_script "init-server.sh" && \
    run_script "init-docker.sh" && \
    run_script "init-plex.sh"
  echo "* butterfinger setup done!"
}

main "$@"
