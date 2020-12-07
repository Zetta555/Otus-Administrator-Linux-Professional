#!/bin/bash

# для расшареной папки
cd /tmp
wget -c http://download.virtualbox.org/virtualbox/6.1.16/VBoxGuestAdditions_6.1.16.iso -O VBoxGuestAdditions_6.1.16.iso
mount VBoxGuestAdditions_6.1.16.iso -o loop /mnt/
cd /mnt
source /opt/rh/devtoolset-8/enable
bash /mnt/VBoxLinuxAdditions.run --nox11
usermod -aG vboxsf vagrant
cp /opt/VBoxGuestAdditions-6.1.16/other/mount.vboxsf /sbin
cd /tmp
sudo -f rm *.iso
#echo 'VirtualBoxSF   /mnt/sf   vboxsf   defaults  0   0' >> /etc/fstab
#Reboot VM
shutdown -r now
