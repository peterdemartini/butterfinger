#!/bin/bash

if [ -z "$BASE_DIR" ]; then
  source '/tmp/butterfinger-scripts/base.sh'
fi

B2_FUSE_DIR="$PROJECTS_DIR/b2_fuse"

install_encfs() {
  if [ -z "$(which encfs)" ]; then
    echo '* installing encfs'
    sudo apt-get -y install encfs
  fi
}

download_b2_fuse(){
  if [ -d "$B2_FUSE_DIR" ]; then
    echo '* updating b2_fuse'
    pushd "$B2_FUSE_DIR"
      git pull
    popd
  else
    echo '* download b2_fuse'
    git clone https://github.com/sondree/b2_fuse.git "$B2_FUSE_DIR"
  fi
}

install_fusepy() {
  pushd "$B2_FUSE_DIR"
    echo '* installing python-yaml python-pip'
    sudo apt-get install -y python-yaml python-pip || return 1
    if [ -z "$(which fusepy)" ]; then
      echo '* install fusepy'
      sudo python -m pip install fusepy || return 1
    fi
  popd
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
    if [ "$?" != "0" ]; then
      sudo rm -rf "$folder_data"
    fi
    create_fuse_folder "$folder_data"
  fi
  if [ -d "$folder_secure" ]; then
    echo "* removing fuse secure $name"
    sudo rm -rf "$folder_secure"
    create_fuse_folder "$folder_secure"
  fi

  echo "* mounting $name : $config_path"
  (cat "$CONFIG_DIR/encfs-passwd" | \
    encfs -S "$folder_secure" \
    "$folder_data" \
    -o nonempty) || return 0
}

setup_local_data() {
  echo '* setting up local data'
  local config_path=""
  if [ -f "$ENCFS_LOCAL_CONFIG_FILE" ]; then
    config_path="$ENCFS_LOCAL_CONFIG_FILE"
  fi

  mount_encrypt_fs 'local' "$config_path" && \
    cp "$PLEX_DATA_DIR/.local-secure/.encfs6.xml" "$ENCFS_LOCAL_CONFIG_FILE"
}

setup_b2_data() {
  echo '* setting up b2 data'
  local config_path=""
  if [ -f "$ENCFS_B2_CONFIG_FILE" ]; then
    config_path="$ENCFS_B2_CONFIG_FILE"
  fi
  mount_encrypt_fs 'b2' "$config_path" && \
    cp "$PLEX_DATA_DIR/.b2-secure/.encfs6.xml" "$ENCFS_B2_CONFIG_FILE"
}

write_encfs_password() {
  echo '* writing encfs password'
  echo "$BUTTERFINGER_PASSWORD" | tee $CONFIG_DIR/encfs-passwd
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
    write_encfs_password && \
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
