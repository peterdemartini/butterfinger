#!/bin/bash

adduser butterfinger
usermod -aG sudo butterfinger
echo 'butterfinger ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
