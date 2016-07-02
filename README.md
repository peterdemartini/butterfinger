# butterfinger

Automated setup of Plex on Linode and B2. I call it butterfinger.

Set a Linode instance with OS Ubuntu 16.04. Then run the following command for setting up the server from the root account:

```bash
env \
  PLEX_USERNAME='[plex-username]' \
  PLEX_PASSWORD='[plex-password]' \
  BUTTERFINGER_PASSWORD='[butterfinger-user-password]' \
  ROOT_PASSWORD='[root-user-password]' \
  B2_APP_KEY='[b2-app-key]' \
  B2_ACCOUNT_ID='[b2-account-id]' \
  B2_BUCKET_ID='[b2-bucket-id]' \
  ./run-from-local.sh root '[hostname]'
```

Or if the butterfinger user is already setup, run:

```bash
env \
  PLEX_USERNAME='[plex-username]' \
  PLEX_PASSWORD='[plex-password]' \
  BUTTERFINGER_PASSWORD='[butterfinger-user-password]' \
  ROOT_PASSWORD='[root-user-password]' \
  B2_APP_KEY='[b2-app-key]' \
  B2_ACCOUNT_ID='[b2-account-id]' \
  B2_BUCKET_ID='[b2-bucket-id]' \
  ./run-from-local.sh user '[hostname]'
```
