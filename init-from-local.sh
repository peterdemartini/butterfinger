#!/bin/bash

BUTTERFINGER_IDENTITY="$HOME/.ssh/butterfinger_id_rsa"

ssh_to_server_as_root() {
  echo "* sshing to root"
  local hostname="$1"
  ssh "root@$1" 'bash -s' < "./setup-user.sh"
}

copy_key() {
  echo "* copying key to server"
  local hostname="$1"
  ssh-copy-id -i "$BUTTERFINGER_IDENTITY" butterfinger@"$hostname"
}

add_key() {
  echo "* adding key"
  ssh-add "$BUTTERFINGER_IDENTITY"
}

ssh_to_server_as_butterfinger() {
  local hostname="$1"
  ssh "butterfinger@$hostname" 'bash -s' < "./start-init.local.sh"
}

main() {
  local hostname="$1"
  if [ -z "$hostname" ]; then
    echo "Missing hostname argument"
    exit 1
  fi
  if [ ! -f "$BUTTERFINGER_IDENTITY" ]; then
    echo "You are missing the butterfinger identity"
    exit 1
  fi
  echo "* setting up locally"
  ssh_to_server_as_butterfinger "$hostname"
  ssh_to_server_as_root "$hostname"
  add_key "$hostname"
  ssh_to_server_as_butterfinger "$hostname"
  echo "* done."
}

main "$@"
