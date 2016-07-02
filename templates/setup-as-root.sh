if ["$(whoami)" != 'root' ]; then
  echo 'This script must be run as the root user.'
  exit 1
fi
adduser butterfinger --disabled-password --gecos 'Mr Butterfinger,5,5,5'
echo 'butterfinger:[password]' | chpasswd
usermod -aG sudo butterfinger
cat /etc/sudoers | grep 'butterfinger ALL=(ALL) NOPASSWD: ALL' > /dev/null \
  && echo 'user exists' || \
  echo 'butterfinger ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
