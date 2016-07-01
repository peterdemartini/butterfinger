#!/bin/bash

adduser butterfinger --disabled-password --quiet
usermod -aG sudo butterfinger
cat /etc/sudoers | grep 'butterfinger' > /dev/null || exit 1
echo 'butterfinger ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
