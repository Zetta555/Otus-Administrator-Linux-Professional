#!/bin/bash

yum install -y nfs-utils nfs-utils-lib firewalld
systemctl enable firewalld
systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start firewalld
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap
mkdir -p /media/nfs_share
chmod -R 0777 /media/nfs_share
firewall-cmd --permanent --add-port=111/tcp
firewall-cmd --permanent --add-port=54302/tcp
firewall-cmd --permanent --add-port=20048/tcp
firewall-cmd --permanent --add-port=2049/tcp
firewall-cmd --permanent --add-port=46666/tcp
firewall-cmd --permanent --add-port=42955/tcp
firewall-cmd --permanent --add-port=875/tcp
firewall-cmd --permanent --add-port=111/udp
firewall-cmd --permanent --add-port=54302/udp
firewall-cmd --permanent --add-port=20048/udp
firewall-cmd --permanent --add-port=2049/udp
firewall-cmd --permanent --add-port=46666/udp
firewall-cmd --permanent --add-port=42955/udp
firewall-cmd --permanent --add-port=875/udp
firewall-cmd --permanent --zone=public --add-service=nfs
firewall-cmd --permanent --zone=public --add-service=mountd
firewall-cmd --permanent --zone=public --add-service=rpc-bind
firewall-cmd --reload
mount -t nfs -o proto=udp,vers=3  192.168.50.10:/upload /media/nfs_share
echo "192.168.50.10:/upload /media/nfs_share nfs rw,vers=3,sync,proto=udp,rsize=32768,wsize=32768 0 0" >> /etc/fstab
