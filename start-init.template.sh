#!/bin/bash

start(){
  local base_uri="https://raw.githubusercontent.com/peterdemartini/butterfinger"
  curl -s "$base_uri/master/init.sh" | env \
    PLEX_USERNAME='[username]' \
    PLEX_PASSWORD='[password]' \
    bash
}

main() {
  start
}

main "$@"
