#!/bin/bash

if [ -z "$BASE_DIR" ]; then
  source '/tmp/butterfinger-scripts/base.sh'
fi

stop_if_needed() {
  echo '* stopping plex service if needed'
  sudo systemctl stop "$PLEX_SERVICE_NAME" 2> /dev/null || return 0
}

download_service_file() {
  download_file 'services' "$PLEX_SERVICE_NAME.service" "$SERVICES_DIR"
}

enable_service() {
  sudo systemctl enable "$BASE_DIR/$PLEX_SERVICE_NAME.service" > /dev/null
}

start_service() {
  echo '* starting service'
  sudo systemctl start "$PLEX_SERVICE_NAME"
}

main() {
  echo '* running plex.sh...'
  if [ -z "$PLEX_USERNAME" ]; then
    echo 'Missing PLEX_USERNAME env'
    exit 1
  fi
  if [ -z "$PLEX_PASSWORD" ]; then
    echo 'Missing PLEX_PASSWORD env'
    exit 1
  fi

  # stop_if_needed && \
  #   write_env && \
  #   download_service_file && \
  #   enable_service && \
  #   start_service && \
  #   echo '* done.' && \
  #   exit 0
  #
  # echo '* failed to run init-plex.sh'
  # exit 1
}

main "$@"
