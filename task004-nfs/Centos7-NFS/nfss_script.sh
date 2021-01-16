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
mkdir /upload
chmod -R 0777 /upload
echo "/upload 192.168.50.11(rw,sync,no_root_squash,no_all_squash)" > /etc/exports
exportfs -r
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

