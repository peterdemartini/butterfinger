#!/bin/bash

BASE_DIR='/opt/butterfinger'
CONFIG_DIR="$BASE_DIR/config"
MOVIE_DIR="$BASE_DIR/data"
SERVICES_DIR="$BASE_DIR/services"
PLEX_ENV_FILE="$BASE_DIR/env/plex-media-server.list"
PLEX_SERVICE_NAME='plex-media-server'
DOCKER_IMAGE='timhaak/plexpass'

setup() {
  echo '* creating directories for plex'
  sudo mkdir -p "$BASE_DIR"
  sudo mkdir -p "$CONFIG_DIR"
  sudo mkdir -p "$MOVIE_DIR"
  sudo mkdir -p "$(dirname "$PLEX_ENV_FILE")"
  sudo mkdir -p "$SERVICES_DIR"
  sudo chmod -R 0775 "$BASE_DIR"
  sudo chgrp -R butterfinger "$BASE_DIR"
}

stop_if_needed() {
  echo '* stopping plex service if needed'
  sudo systemctl stop "$PLEX_SERVICE_NAME" 2> /dev/null || return 0
}

write_env() {
  echo '* writing env for plex'
  echo 'SKIP_CHOWN_CONFIG=false' | tee "$PLEX_ENV_FILE"
  echo "PLEX_USERNAME=$PLEX_USERNAME" | tee --append  "$PLEX_ENV_FILE"
  echo "PLEX_PASSWORD=$PLEX_PASSWORD" | tee --append  "$PLEX_ENV_FILE"
  echo 'PLEX_EXTERNALPORT=80' | tee --append  "$PLEX_ENV_FILE"
  # echo "PLEX_TOKEN=" >> "$PLEX_ENV_FILE"
}

download_service_file() {
  echo '* downloading plex service file'
  local repo='https://raw.githubusercontent.com/peterdemartini/butterfinger'
  sudo curl -sSL "${repo}/master/services/$PLEX_SERVICE_NAME.service?r=${RANDOM}" -o "$SERVICES_DIR/$PLEX_SERVICE_NAME.service" || return 1
  sudo systemctl enable "$SERVICES_DIR/$PLEX_SERVICE_NAME.service"
}

start_service() {
  echo '* starting service'
  sudo systemctl start "$PLEX_SERVICE_NAME"
}

main() {
  echo '* running init-plex.sh...'
  if [ -z "$PLEX_USERNAME" ]; then
    echo 'Missing PLEX_USERNAME env'
    exit 1
  fi
  if [ -z "$PLEX_PASSWORD" ]; then
    echo 'Missing PLEX_PASSWORD env'
    exit 1
  fi
  setup && \
    stop_if_needed && \
    write_env && \
    download_service_file && \
    start_service && \
    echo '* done.' && \
    exit 0

  echo '* failed to run init-plex.sh'
  exit 1
}

main "$@"
