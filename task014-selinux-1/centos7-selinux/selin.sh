#! /bin/bash

yum install -y epel-release
yum install -y policycoreutils-python policycoreutils-devel policycoreutils-newrole policycoreutils-restorecond setools-console
yum install -y nginx
systemctl enable nginx --now