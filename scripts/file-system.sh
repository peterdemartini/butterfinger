#!/bin/bash

source '/tmp/butterfinger-scripts/base.sh'

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
  python "$B2_FUSE_DIR/b2fuse.py" "$PLEX_DATA_DIR/.b2-secure"
}

mount_encrypt_fs() {
  local name="$1"
  encfs "$PLEX_DATA_DIR/.${name}-secure" "$PLEX_DATA_DIR/${name}-data"
}

setup_local_data() {
  if [ -f "$ENCFS_LOCAL_CONFIG_FILE" ]; then
    env ENCFS6_CONFIG="$ENCFS_LOCAL_CONFIG_FILE" mount_encrypt_fs 'local'
  else
    mount_encrypt_fs 'local'
    cp "$PLEX_DATA_DIR/.b2-secure/encfs.xml" "$ENCFS_LOCAL_CONFIG_FILE"
  fi
}

setup_b2_data() {
  if [ -f "$ENCFS_B2_CONFIG_FILE" ]; then
    env ENCFS6_CONFIG="$ENCFS_B2_CONFIG_FILE" mount_encrypt_fs 'b2'
  else
    mount_encrypt_fs 'b2'
    cp "$PLEX_DATA_DIR/.b2-secure/encfs.xml" "$ENCFS_B2_CONFIG_FILE"
  fi
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
