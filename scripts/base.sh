#!/bin/bash

export BASE_DIR='/opt/butterfinger'
export PLEX_CONFIG_DIR="$BASE_DIR/plex/config"
export PLEX_DATA_DIR="$BASE_DIR/data"
export SERVICES_DIR="$BASE_DIR/services"
export PROJECTS_DIR="$BASE_DIR/projects"
export CONFIG_DIR="$BASE_DIR/config"
export PLEX_ENV_FILE="$CONFIG_DIR/plex-media-server.env"
export ENCFS_LOCAL_CONFIG_FILE="$CONFIG_DIR/encfs-local.xml"
export ENCFS_B2_CONFIG_FILE="$CONFIG_DIR/encfs-b2.xml"
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

create_dir() {
  local folder="$1"
  echo "* create folder $1"
  sudo mkdir -p "$folder"
  sudo chmod -R 0775 "$folder"
  sudo chgrp -R butterfinger "$folder"
}

create_fuse_folder() {
  local folder="$1"
  if [ ! -d "$folder" ]; then
    echo "* create fuse folder $1"
    create_dir "$folder"
  fi
}


export -f download_file
export -f download_script
export -f create_dir
export -f create_fuse_folder
