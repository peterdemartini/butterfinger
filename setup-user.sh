#!/bin/bash

adduser butterfinger
usermod -aG sudo butterfinger
(cat /etc/sudoers | grep 'butterfinger') || \
  echo 'butterfinger ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
