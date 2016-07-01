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
  curl -fsS "${repo}/master/${script}" -o "${SCRIPTS_DIR}/${script}" || exit 1
  chmod +x "${SCRIPTS_DIR}/${script}"
}

run_script() {
  echo "* running script"
  local script="$1"
  "${SCRIPTS_DIR}/${script}" || exit 1
}

main() {
  echo "* starting butterfinger setup"
  sudo touch /tmp/.enable-sudo-at-first
  create_scripts_dir || exit 1
  download_script "init-server.sh" || exit 1
  download_script "init-docker.sh" || exit 1
  download_script "init-plex.sh" || exit 1
  run_script "init-server.sh" || exit 1
  run_script "init-docker.sh" || exit 1
  run_script "init-plex.sh" || exit 1
  echo "* butterfinger setup done!"
}

main "$@"
