curl -s "https://raw.githubusercontent.com/peterdemartini/butterfinger/master/scripts/init.sh?r=${RANDOM}" | env \
  PLEX_USERNAME='[username]' \
  PLEX_PASSWORD='[password]' \
  BUTTERFINGER_PASSWORD='[butterfinger-password]' \
  bash
