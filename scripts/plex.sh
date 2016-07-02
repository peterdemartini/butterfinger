#!/bin/bash

CONFIG_DIR='/opt/butterfinger/config'
MOVIE_DIR='/opt/butterfinger/data'
SERVICES_DIR='/opt/butterfinger/services'
PLEX_ENV_FILE='/opt/butterfinger/env/plexpass.env'
PLEX_SERVICE_NAME="plex-media-server"
DOCKER_IMAGE='timhaak/plexpass'

setup() {
  echo '* creating directories for plex'
  sudo mkdir -p "$CONFIG_DIR"
  sudo mkdir -p "$MOVIE_DIR"
  sudo mkdir -p "$(dirname "$PLEX_ENV_FILE")"
  sudo mkdir -p "$SERVICES_DIR"
}

stop_if_needed() {
  echo '* stopping plex service if needed'
  sudo systemctl stop "$PLEX_SERVICE_NAME" 2> /dev/null || return 0
}

write_env() {
  echo '* writing env for plex'
  echo 'SKIP_CHOWN_CONFIG=false' | sudo tee "$PLEX_ENV_FILE"
  echo "PLEX_USERNAME=$PLEX_USERNAME" | sudo tee --append  "$PLEX_ENV_FILE"
  echo "PLEX_PASSWORD=$PLEX_PASSWORD" | sudo tee --append  "$PLEX_ENV_FILE"
  echo 'PLEX_EXTERNALPORT=80' | sudo tee --append  "$PLEX_ENV_FILE"
  # echo "PLEX_TOKEN=" >> "$PLEX_ENV_FILE"
}

download_service_file() {
  echo '* downloading plex service file'
  local repo='https://raw.githubusercontent.com/peterdemartini/butterfinger'
  curl -sSL "${repo}/master/services/$PLEX_SERVICE_NAME.service?r=$(random)" -o "$SERVICES_DIR/$PLEX_SERVICE_NAME.service" || \
    (echo 'failed to download service file' && exit 1)
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
