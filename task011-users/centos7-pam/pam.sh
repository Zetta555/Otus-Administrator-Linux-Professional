#! /bin/bash

yum install -y epel-release
yum install -y pam_script

# Установливаю Docker
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io mc
systemctl enable docker
systemctl start docker

#
useradd day
useradd friday

echo "Otus2021" | passwd --stdin day
echo "Otus2021" | passwd --stdin friday

groupadd admin
usermod -aG admin day
usermod -aG wheel day

sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
sed -i -e '2 s/^/auth  required  pam_script.so\n/;' /etc/pam.d/sshd

cat <<'EOT' > /etc/pam_script
#!/bin/bash
if [[ `grep $PAM_USER /etc/group | grep 'admin'` ]]
then
exit 0
fi
if [[ `date +%u` > 5 ]]
then
exit 1
fi
EOT
chmod +x /etc/pam_script
systemctl restart sshd