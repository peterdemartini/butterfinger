#!/bin/bash

if [ -z "$BASE_DIR" ]; then
  source '/tmp/butterfinger-scripts/base.sh'
fi

B2_FUSE_DIR="$PROJECTS_DIR/b2_fuse"

install_encfs() {
  echo '* install encfs'
  sudo apt-get -y install encfs
}

download_b2_fuse(){
  echo '* download b2_fuse'
  git clone https://github.com/sondree/b2_fuse.git "$B2_FUSE_DIR"
}

install_fusepy() {
  echo '* install fusepy'
  sudo apt-get install -y python-yaml python-pip || return 1
  sudo python -m pip install fusepy || return 1
}

mount_b2_fuse() {
  echo '* mount b2 fuse'
  pushd "$B2_FUSE_DIR"
    python "$B2_FUSE_DIR/b2fuse.py" "$PLEX_DATA_DIR/.b2-secure"
  popd
}

mount_encrypt_fs() {
  local name="$1"
  local config_path="$2"
  local folder_data="$PLEX_DATA_DIR/${name}-data"
  local folder_secure="$PLEX_DATA_DIR/.${name}-secure"
  echo "* mount encryted $name"
  if [ -d "$folder_data" ]; then
    echo "* unmounting fuse unsecure $name"
    fusermount -u "$folder_data"
    create_fuse_folder "$folder_data"
  fi
  if [ -d "$folder_secure" ]; then
    echo "* removing fuse secure $name"
    sudo rm -rf "$folder_secure"
    create_fuse_folder "$folder_secure"
  fi
  echo '* mounting'

  (echo "$BUTTERFINGER_PASSWORD" | env ENCFS6_CONFIG="$config_path" \
    encfs -S "$folder_secure" \
    "$folder_data" \
    -o nonempty) || return 0
}

setup_local_data() {
  echo '* setting up local data'
  mount_encrypt_fs 'local' "$ENCFS_LOCAL_CONFIG_FILE" && \
    cp "$PLEX_DATA_DIR/.local-secure/.encfs6.xml" "$ENCFS_LOCAL_CONFIG_FILE"
}

setup_b2_data() {
  echo '* setting up b2 data'
  mount_encrypt_fs 'b2' "$ENCFS_B2_CONFIG_FILE" && \
    cp "$PLEX_DATA_DIR/.b2-secure/.encfs6.xml" "$ENCFS_B2_CONFIG_FILE"
}

write_b2_fuse_config(){
  echo '* writing b2_fuse config'
  local file_path="$B2_FUSE_DIR/config.yaml"
  echo "accountId: $B2_ACCOUNT_ID" | tee "$file_path"
  echo "applicationKey: $B2_APP_KEY" | tee --append  "$file_path"
  echo "bucketId: $B2_BUCKET_ID" | tee --append  "$file_path"
}

main() {
  echo '* running file-system.sh...'
  install_encfs && \
    setup_local_data && \
    setup_b2_data && \
    download_b2_fuse && \
    install_fusepy && \
    write_b2_fuse_config && \
    mount_b2_fuse && \
    echo '* done.' && \
    exit 0
}

main "$@"
