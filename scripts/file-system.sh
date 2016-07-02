#!/bin/bash

source ./base.sh

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
  python "$B2_FUSE_DIR/b2local.py" "$PLEX_DATA_DIR/.b2-secure" "$PLEX_DATA_DIR/b2-data"
}

setup_local() {
  encfs "$PLEX_DATA_DIR/.local-secure" "$PLEX_DATA_DIR/local-data"
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
    setup_local && \
    download_b2_fuse && \
    install_fusepy && \
    write_b2_fuse_config && \
    mount_b2_fuse && \
    echo '* done.' && \
    exit 0
}

main "$@"
