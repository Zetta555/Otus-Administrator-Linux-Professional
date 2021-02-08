#! /bin/bash

useradd day
useradd night
useradd friday
echo "Otus2021" | passwd --stdin day
echo "Otus2021" | passwd --stdin night
echo "Otus2021" | passwd --stdin friday
bash -c "sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication yes/' /etc/ssh/sshd_config && systemctl restart sshd.service"
setenforce 0
groupadd admin
usermod -aG admin root
usermod -aG admin vagrant