(cat '/etc/ssh/sshd_config' | grep 'PasswordAuthentication' > /dev/null) && \
  sed -i.bak 's/.*PasswordAuthentication.*/PasswordAuthentication no/' '/etc/ssh/sshd_config'
systemctl reload sshd
