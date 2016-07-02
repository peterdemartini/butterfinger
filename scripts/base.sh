#!/bin/bash

export BASE_DIR='/opt/butterfinger'
export PLEX_CONFIG_DIR="$BASE_DIR/plex/config"
export PLEX_DATA_DIR="$BASE_DIR/data"
export SERVICES_DIR="$BASE_DIR/services"
export PROJECTS_DIR="$BASE_DIR/projects"
export CONFIG_DIR="$BASE_DIR/config"
export PLEX_ENV_FILE="$CONFIG_DIR/plex-media-server.env"
export ENCFS6_CONFIG="$CONFIG_DIR/encfs.xml"
export PLEX_SERVICE_NAME='plex-media-server'
export SCRIPT_BASE_URI='https://raw.githubusercontent.com/peterdemartini/butterfinger'
export SCRIPTS_DIR='/tmp/butterfinger-scripts'

download_file() {
  echo '* downloading service file'
  local file_path="$1"
  curl -sSL "${SCRIPT_BASE_URI}/master/${file_path}?r=${RANDOM}" -o "$file_path" || return 1
}

download_script(){
  local script="$1"
  local file_path="${SCRIPTS_DIR}/${script}"
  echo "* downloading $script"
  rm "$file_path" &> /dev/null
  curl -sSL "${SCRIPT_BASE_URI}/master/scripts/${script}?r=${RANDOM}" -o "$file_path" || exit 1
  chmod +x "$file_path"
}
