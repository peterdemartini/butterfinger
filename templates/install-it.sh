curl -s "https://raw.githubusercontent.com/peterdemartini/butterfinger/master/scripts/init.sh?r=${RANDOM}" | env \
  PLEX_USERNAME='[plex-username]' \
  PLEX_PASSWORD='[plex-password]' \
  BUTTERFINGER_PASSWORD='[butterfinger-password]' \
  bash
