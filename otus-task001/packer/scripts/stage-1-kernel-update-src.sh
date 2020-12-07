#!/bin/bash

# Install new kernel
# Установка необходимых пакетов для обновления ядра из исходников
yum update -y
yum install -y wget
yum groupinstall -y "Development Tools"
# подготовка компилятора
yum install -y centos-release-scl
yum install -y devtoolset-8
source /opt/rh/devtoolset-8/enable
yum install -y openssl-devel elfutils-libelf-devel ncurses-devel bc yum kernel-devel kernel-headers rpm-build
# скачиваем исходники, распаковываем, готовим ядро к сборке
cd /tmp
wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.9.3.tar.xz
tar -xvf linux-5.9.3.tar.xz -C /usr/src
cd /usr/src/linux-5.9.3/
/bin/cp -rf /boot/config-$(uname -r)* .config
yes "" | make oldconfig
make -j9 rpm-pkg
/usr/bin/rpm -iUh --nodeps ~/rpmbuild/RPMS/x86_64/kernel-*.rpm
#make
#make modules_install install
# Remove older kernels (Only for demo! Not Production!)
rm -f /boot/*3.10*
# Update GRUB
grub2-mkconfig -o /boot/grub2/grub.cfg
grub2-set-default 0
echo "Grub update done."
# Reboot VM
shutdown -r now
