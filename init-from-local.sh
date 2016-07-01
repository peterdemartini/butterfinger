#!/bin/bash

BUTTERFINGER_IDENTITY="$HOME/.ssh/butterfinger_id_rsa"

get_first_commands() {
  echo "* Run this commands"
  echo "  adduser butterfinger"
  echo "  usermod -aG sudo butterfinger"
  echo "  cat /etc/sudoers | grep 'butterfinger'"
  echo "  echo 'butterfinger ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"
}

ssh_to_server_as_root() {
  echo "* sshing to root"
  get_first_commands
  local ip="$1"
  ssh "root@$1" "$(get_first_commands)"
}

copy_key() {
  echo "* copying key to server"
  local ip="$1"
  ssh-copy-id -i "$BUTTERFINGER_IDENTITY" butterfinger@"$ip"
}

add_key() {
  echo "* adding key"
  ssh-add "$BUTTERFINGER_IDENTITY"
}

ssh_to_server_as_butterfinger() {
  ssh "butterfinger@$ip"
}

main() {
  local ip="$1"
  if [ -z "$ip" ]; then
    echo "Missing ip argument"
    exit 1
  fi
  if [ ! -f "$BUTTERFINGER_IDENTITY" ]; then
    echo "You are missing the butterfinger identity"
    exit 1
  fi
  echo "* setting up locally"
  ssh_to_server_as_root "$ip"
  add_key "$ip"
  ssh_to_server_as_butterfinger
  echo "* done."
}

main "$@"
