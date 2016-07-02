(whoami | grep -v 'root') \
  && echo 'This script must be run as the root user.' && exit 1
(cut -d: -f1 /etc/passwd | grep -v 'butterfinger') && adduser butterfinger --disabled-password --gecos 'Mr Butterfinger,5,5,5'
echo 'butterfinger:[password]' | chpasswd
usermod -aG sudo butterfinger
cat /etc/sudoers | grep 'butterfinger ALL=(ALL) NOPASSWD: ALL' > /dev/null \
  && echo 'user exists' || \
  echo 'butterfinger ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers
cat '/etc/ssh/sshd_config' | grep 'PermitRootLogin' && sed -i .bk -e 's/.*PermitRootLogin.*/PermitRootLogin no/' '/etc/ssh/sshd_config'
cat '/etc/ssh/sshd_config' | grep 'PasswordAuthentication' && sed -i .bk -e 's/.*PasswordAuthentication.*/PasswordAuthentication no/' '/etc/ssh/sshd_config'
systemctl reload sshd
