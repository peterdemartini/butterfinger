#!/bin/bash

CONFIG_DIR="/etc/butterfinger"
MOVIE_DIR="/data/butterfinger"
PLEX_ENV_FILE='/tmp/plex-env-file.env'
DOCKER_IMAGE='timhaak/plexpass'

setup() {
  echo "* plex setup"
  mkdir -p "$CONFIG_DIR"
  mkdir -p "$MOVIE_DIR"
}

get_docker_image() {
  echo "* pull $DOCKER_IMAGE"
  docker pull "$DOCKER_IMAGE"
}

preclean() {
  echo "* pre-clean plex run"
  docker rm -f plexpass
}

run_it() {
  echo "* running plex"
  docker run \
    --restart=always \
    --envfile "$PLEX_ENV_FILE"
    -d --name plex \
    -h "$(/etc/hostname)" \
    -v "$CONFIG_DIR:/config" \
    -v "$MOVIE_DIR:/data" \
    -p 32400:32400 "$DOCKER_IMAGE"
}

write_env() {
  echo "* writing env for plex"
  echo "SKIP_CHOWN_CONFIG=false" > "$PLEX_ENV_FILE"
  echo "PLEX_USERNAME=$PLEX_USERNAME" >> "$PLEX_ENV_FILE"
  echo "PLEX_PASSWORD=$PLEX_PASSWORD" >> "$PLEX_ENV_FILE"
  echo "PLEX_EXTERNALPORT=80" >> "$PLEX_ENV_FILE"
  # echo "PLEX_TOKEN=" >> "$PLEX_ENV_FILE"
}

main() {
  echo "running init-plex.sh..."
  if [ -z "$PLEX_USERNAME" ]; then
    echo "Missing PLEX_USERNAME env"
    exit 1
  fi
  if [ -z "$PLEX_PASSWORD" ]; then
    echo "Missing PLEX_PASSWORD env"
    exit 1
  fi
  setup || exit 1
  write_env || exit 1
  get_docker_image || exit 1
  preclean || exit 1
  run_it || exit 1
  echo "* done."
}

main "$@"
