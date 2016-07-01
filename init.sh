#!/bin/bash

SCRIPTS_DIR='/tmp/butterfinger-scripts'

create_scripts_dir() {
  echo "* creating butterfinger-scripts dir"
  rm -rf "$SCRIPTS_DIR"
  mkdir -p "$SCRIPTS_DIR"
}

download_and_run() {
  echo "* download and run"
  local script="$1"
  local repo="https://raw.githubusercontent.com/peterdemartini/butterfinger"
  curl -fsS "${repo}/master/${script}" -o "/tmp/${script}" || exit 1
  chmod +x "/tmp/${script}" || exit 1
  "/tmp/${script}" || exit 1
}

main() {
  echo "* starting butterfinger setup"
  sudo /tmp/.enable-sudo-at-first
  create_scripts_dir || exit 1
  download_and_run "./init-server.sh" || exit 1
  download_and_run "./init-docker.sh" || exit 1
  download_and_run "./init-plex.sh" || exit 1
  echo "* butterfinger setup done!"
}

main "$@"
