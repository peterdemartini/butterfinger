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

usage() {
  local notice="$1"
  echo "./init-from-local.sh <subcommand> <hostname>"
  echo ""
  echo "subcommands:"
  echo "   init"
  echo "       - assuming butterfinger user is setup, it will auth as it"
  echo "   init-root"
  echo "       - first create butterfinger user"
  echo ""
  if [ "$notice" != "" ]; then
    echo "$notice"
    echo ""
  fi
}

main() {
  local cmd="$1"
  local hostname="$2"

  if [ -z "$cmd" ]; then
    usage 'Missing command argument'
    exit 1
  fi

  if [ "$cmd" != 'init-root' ] && [ "$cmd" != "init" ]; then
    usage 'Command must be either "init-root" or "init"'
    exit 1
  fi

  if [ -z "$hostname" ]; then
    usage 'Missing hostname argument'
    exit 1
  fi

  if [ ! -f "$BUTTERFINGER_IDENTITY" ]; then
    usage 'You are missing the butterfinger identity'
    exit 1
  fi

  echo "* setting up locally"
  if [ "$cmd" == "init" ]; then
    ssh_to_server_as_butterfinger "$hostname"
  fi
  if [ "$cmd" == "init-root" ]; then
    ssh_to_server_as_root "$hostname" && \
      add_key "$hostname" && \
      ssh_to_server_as_butterfinger "$hostname"
  fi
  echo "* done."
}

main "$@"
