#!/bin/bash

BUTTERFINGER_IDENTITY="$HOME/.ssh/butterfinger_id_rsa"

ssh_to_server_as_root() {
  echo '* sshing to root'
  local hostname="$1"
  ssh "root@$hostname" 'bash -s' < './generated/setup-as-root.sh'
}

copy_key() {
  local user="$1"
  local hostname="$2"
  echo "* copying key to server for $user"
  ssh-copy-id -i "$BUTTERFINGER_IDENTITY" "$user"@"$hostname" > /dev/null
}

copy_password() {
  local password="$1"
  if [ -z "$password" ]; then
    return 0
  fi
  echo "* copying password $password"
  printf "$BUTTERFINGER_PASSWORD" | pbcopy
}

add_key() {
  echo '* adding key'
  ssh-add "$BUTTERFINGER_IDENTITY" > /dev/null
}

ssh_to_server_as_butterfinger() {
  echo '* ssh into butterfinger'
  local hostname="$1"
  ssh "butterfinger@$hostname" 'bash -s' < './generated/install-it.sh'
}

get_oauth_data() {
  local oauth_data_path="$1"
  if [ ! -f "$oauth_data_path" ]; then
    echo '* opening auth in window'
    echo "* download the oauth_data file to the \"$oauth_data_path\""
    open "https://tensile-runway-92512.appspot.com"
  fi
}

upload_to_butterfinger() {
  local hostname="$1"
  local from="$2"
  local to="$3"
  echo "* uploading to butterfinger $to"
  local to_dir="$(dirname /home/butterfinger/$to)"
  ssh "butterfinger@${hostname}" "mkdir -p $to_dir" && \
    scp -q "$from" "butterfinger@$hostname:/home/butterfinger/$to"
}

usage() {
  local notice="$1"
  echo './init-from-local.sh <subcommand> <hostname>'
  echo ''
  echo 'subcommands:'
  echo ' user'
  echo '   - assuming butterfinger user is setup, it will auth as it'
  echo ' root'
  echo '   - first create butterfinger user'
  echo 'required enviromnent:'
  echo '  PLEX_USERNAME'
  echo '  PLEX_PASSWORD'
  echo '  BUTTERFINGER_PASSWORD'
  echo ''
  if [ "$notice" != '' ]; then
    echo "$notice"
    echo ''
  fi
}

generate_install_it() {
  echo '* generate install-it.sh'
  copy_template 'install-it.sh' && \
    replace_in_generated 'install-it.sh' 'plex-username' "$PLEX_USERNAME" && \
    replace_in_generated 'install-it.sh' 'plex-password' "$PLEX_PASSWORD" && \
    replace_in_generated 'install-it.sh' 'butterfinger-password' "$BUTTERFINGER_PASSWORD"
}

generate_setup_as_root(){
  echo '* generate setup-as-root.sh'
  copy_template 'setup-as-root.sh' && \
    replace_in_generated 'setup-as-root.sh' 'butterfinger-password' "$BUTTERFINGER_PASSWORD"
}

generate_config_and_upload() {
  local hostname="$1"
  local config_file="$2"
  local generated_config_dir="$PWD/generated/config"
  if [ ! -d "$generated_config_dir" ]; then
    mkdir -p "$generated_config_dir" || return 1
  fi
  generate_config "$config_file" && \
    upload_to_butterfinger "$hostname" "$generated_config_dir/$config_file" "config/$config_file"
}

generate_config() {
  local config_file="$1"
  echo "* generating config $config_file"
  copy_template "config/$config_file" && \
    replace_in_generated "config/$config_file" 'plex-username' "$PLEX_USERNAME" && \
    replace_in_generated "config/$config_file" 'plex-password' "$PLEX_PASSWORD" && \
    replace_in_generated "config/$config_file" 'butterfinger-password' "$BUTTERFINGER_PASSWORD"
}

copy_template() {
  local template_name="$1"
  echo "* copying from template $template_name"
  cp "./templates/$template_name" "./generated/$template_name"
}

wait_for_oauth_data() {
  local oauth_data_path="$1"
  while [ ! -f "$oauth_data_path" ]
  do
    echo '* waiting for oauth_data'
    sleep 2
  done
}

replace_in_generated() {
  local template_name="$1"
  local key="$2"
  local value="$(echo "$3" | sed -e 's/[\/&]/\\&/g')"
  local file="./generated/$template_name"
  echo "* replacing $key in template $template_name"
  if [ ! -f "$file" ]; then
    echo "Missing generated template $file"
    return 1
  fi
  sed -i .bk -e "s/\[$key\]/$value/" "$file"
  if [ -f "$file.bk" ]; then
    rm "$file.bk"
  fi
  return 0
}

remove_from_known_hosts(){
  echo "* removing from known_hosts"
  local hostname="$1"
  local hostname="$(echo "$1" | sed -e 's/[\/&]/\\&/g')"
  local file="$HOME/.ssh/known_hosts"
  sed -i .bk -e "s/^$hostname.*//" "$file"
  if [ -f "$file.bk" ]; then
    rm "$file.bk"
  fi
}

main() {
  local cmd="$1"
  local hostname="$2"
  local oauth_data_path="$PWD/secrets/oauth_data"

  if [ -z "$cmd" ]; then
    usage 'Missing command argument'
    exit 1
  fi

  if [ -z "$hostname" ]; then
    usage 'Missing hostname argument'
    exit 1
  fi

  if [ ! -f "$BUTTERFINGER_IDENTITY" ]; then
    usage "You are missing the butterfinger identity ($BUTTERFINGER_IDENTITY)"
    exit 1
  fi

  if [ -z "$BUTTERFINGER_PASSWORD" ]; then
    usage 'You are missing the BUTTERFINGER_PASSWORD enviromnent'
    exit 1
  fi

  if [ -z "$PLEX_USERNAME" ]; then
    usage 'You are missing the PLEX_USERNAME enviromnent'
    exit 1
  fi

  if [ -z "$PLEX_PASSWORD" ]; then
    usage 'You are missing the PLEX_PASSWORD enviromnent'
    exit 1
  fi

  generate_install_it && \
    generate_setup_as_root

  if [ "$?" != "0" ]; then
    echo "* failed to write templates"
    exit 1
  fi

  if [ "$cmd" == "root" ]; then
    echo '* running root command'
    remove_from_known_hosts "$hostname" && \
      copy_password "$ROOT_PASSWORD" && \
      copy_key 'root' "$hostname" && \
      ssh_to_server_as_root "$hostname" && \
      copy_password "$BUTTERFINGER_PASSWORD" && \
      copy_key 'butterfinger' "$hostname" && \
      echo '* done with root' && \
      exit 0
    echo '* failed with root'
    exit 1
  fi


  get_oauth_data "$oauth_data_path" && \
    wait_for_oauth_data "$oauth_data_path" && \
    upload_to_butterfinger "$hostname" "$oauth_data_path" 'secrets/oauth_data' && \
    generate_config_and_upload "$hostname" 'acd-encfs.env' && \
    generate_config_and_upload "$hostname" 'acd-mount.env' && \
    generate_config_and_upload "$hostname" 'local-encfs.env' && \
    generate_config_and_upload "$hostname" 'plex-media-server.env' && \
    generate_config_and_upload "$hostname" 'unionfs.env'

  if [ "$?" != "0" ]; then
    echo "* failed to write templates"
    exit 1
  fi

  echo '* setting up locally'

  add_key

  if [ "$cmd" == "user" ]; then
    echo '* running user command'
    ssh_to_server_as_butterfinger "$hostname"
  fi
}

main "$@"
