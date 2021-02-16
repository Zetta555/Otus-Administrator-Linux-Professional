#! /bin/bash

yum install -y epel-release
yum install -y policycoreutils-python
yum install -y nginx
systemctl enable nginx --now