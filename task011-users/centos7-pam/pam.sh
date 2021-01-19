#! /bin/bash

useradd day
useradd night
useradd friday
echo "Otus2021" | passwd --stdin day
echo "Otus2021" | passwd --stdin night
echo "Otus2021" | passwd --stdin friday
bash -c "sed -i 's/^PasswordAuthentication.*$/PasswordAuthentication yes/' /etc/ssh/sshd_config && systemctl restart sshd.service"
echo '*;*;day;Al0800-2000
*;*;night;!Al0800-2000
*;*;friday;Fr' >> /etc/security/time.conf
echo 'account    required     pam_nologin.so
account    required     pam_time.so' >> /etc/pam.d/sshd
