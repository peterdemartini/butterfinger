#!/bin/bash

export BASE_DIR='/opt/butterfinger'
export PLEX_CONFIG_DIR="$BASE_DIR/plex/config"
export PLEX_DATA_DIR="$BASE_DIR/data"
export SERVICES_DIR="$BASE_DIR/services"
export PROJECTS_DIR="$BASE_DIR/projects"
export CONFIG_DIR="$BASE_DIR/config"
export PLEX_ENV_FILE="$CONFIG_DIR/plex-media-server.env"
export PLEX_SERVICE_NAME='plex-media-server'
export SCRIPT_BASE_URI='https://raw.githubusercontent.com/peterdemartini/butterfinger'
export SCRIPTS_DIR='/tmp/butterfinger-scripts'

download_file() {
  echo '* downloading file'
  local from_folder="$1"
  local file="$2"
  local to_dir="$3"
  curl -sSL "${SCRIPT_BASE_URI}/master/${from_folder}/${file}?r=${RANDOM}" -o "$to_dir/$file" || return 1
}

download_script(){
  local script="$1"
  local file_path="${SCRIPTS_DIR}/${script}"
  echo "* downloading $script"
  rm "$file_path" &> /dev/null
  download_file 'scripts' "$script" "$SCRIPTS_DIR"
  chmod +x "$file_path"
}

create_dir() {
  local folder="$1"
  echo "* create folder $1"
  sudo mkdir -p "$folder"
  sudo chmod -R 0775 "$folder"
  sudo chgrp -R butterfinger "$folder"
}

export -f download_file
export -f download_script
export -f create_dir
