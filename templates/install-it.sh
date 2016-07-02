curl -s "https://raw.githubusercontent.com/peterdemartini/butterfinger/master/scripts/init.sh?r=${RANDOM}" | env \
  PLEX_USERNAME='[username]' \
  PLEX_PASSWORD='[password]' \
  B2_ACCOUNT_ID='[b2-account-id]' \
  B2_APP_KEY='[b2-app-key]' \
  B2_BUCKET_ID='[b2-bucket-id]' \
  bash
