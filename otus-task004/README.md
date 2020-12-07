# otus-task004
Работа с NFS.  
Vagrant стенд для NFS.  

- vagrant up должен поднимать 2 виртуалки: сервер и клиент  
- на сервер должна быть расшарена директория  
- на клиента она должна автоматически монтироваться при старте (fstab или autofs)  
- в шаре должна быть папка upload с правами на запись  

\- требования для NFS: NFSv3 по UDP, включенный firewall  
\* Настроить аутентификацию через KERBEROS  

## Ход выполнения основного задания.
1. <summary><code>$> vagrant box add centos/7</code></summary><br/>  

2. <summary><code>$> vagrant init</code></summary><br/>  

3. копирую [Vagranfile](https://cdn.otus.ru/media/private/b7/1b/Vagrantfile-37455-b71b83?hash=ck6IYn61-J_gu7Y2xXFeqw&expires=1605571382 "Vagranfile") из ЛК, комментирую секции provision.<br/>
<details>
<summary>Вывод <code>$> cat Vagrantfile   </code></summary>

```  
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"
  config.vm.box_version = "2004.01"

#  config.vm.provision "ansible" do |ansible|
#    ansible.verbose = "vvv"
#    ansible.playbook = "playbook.yml"
#    ansible.become = "true"
#  end

  config.vm.provider "virtualbox" do |v|
    v.memory = 256
    v.cpus = 1
  end

  config.vm.define "nfss" do |nfss|
    nfss.vm.network "private_network", ip: "192.168.50.10", virtualbox__intnet: "net1"
    nfss.vm.hostname = "nfss"
#    nfss.vm.provision "shell", path: "nfss_script.sh"
  end

  config.vm.define "nfsc" do |nfsc|
    nfsc.vm.network "private_network", ip: "192.168.50.11", virtualbox__intnet: "net1"
    nfsc.vm.hostname = "nfsc"
#    nfsc.vm.provision "shell", path: "nfsc_script.sh"
  end

end
```
</details><br/>  

4. <code>$> vagrant up --provision </code><br/>  

5. Подключаюсь к виртуальной машине, приступаю к настройке NFS-сервера.<br/>    
<code>$> vagrant ssh nfss </code><br/>  

6. Устанавливаю необходимые пакеты NFS-сервиса, обновляю firewall.<br/>  
<details>
<summary>Вывод <code>[root@nfss ~]# yum install -y nfs-utils nfs-utils-lib firewalld    </code></summary>

```  
Failed to set locale, defaulting to C
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.tversu.ru
 * extras: mirror.docker.ru
 * updates: mirror.docker.ru
No package nfs-utils-lib available.
Resolving Dependencies
--> Running transaction check
---> Package firewalld.noarch 0:0.6.3-8.el7_8.1 will be updated
---> Package firewalld.noarch 0:0.6.3-11.el7 will be an update
--> Processing Dependency: python-firewall = 0.6.3-11.el7 for package: firewalld-0.6.3-11.el7.noarch
--> Processing Dependency: firewalld-filesystem = 0.6.3-11.el7 for package: firewalld-0.6.3-11.el7.noarch
---> Package nfs-utils.x86_64 1:1.3.0-0.66.el7 will be updated
---> Package nfs-utils.x86_64 1:1.3.0-0.68.el7 will be an update
--> Running transaction check
---> Package firewalld-filesystem.noarch 0:0.6.3-8.el7_8.1 will be updated
---> Package firewalld-filesystem.noarch 0:0.6.3-11.el7 will be an update
---> Package python-firewall.noarch 0:0.6.3-8.el7_8.1 will be updated
---> Package python-firewall.noarch 0:0.6.3-11.el7 will be an update
--> Finished Dependency Resolution

Dependencies Resolved

==================================================================================================================================================
 Package                                    Arch                         Version                                 Repository                  Size
==================================================================================================================================================
Updating:
 firewalld                                  noarch                       0.6.3-11.el7                            base                       448 k
 nfs-utils                                  x86_64                       1:1.3.0-0.68.el7                        base                       412 k
Updating for dependencies:
 firewalld-filesystem                       noarch                       0.6.3-11.el7                            base                        51 k
 python-firewall                            noarch                       0.6.3-11.el7                            base                       355 k

Transaction Summary
==================================================================================================================================================
Upgrade  2 Packages (+2 Dependent packages)

Total download size: 1.2 M
Downloading packages:
No Presto metadata available for base
warning: /var/cache/yum/x86_64/7/base/packages/firewalld-filesystem-0.6.3-11.el7.noarch.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
Public key for firewalld-filesystem-0.6.3-11.el7.noarch.rpm is not installed
(1/4): firewalld-filesystem-0.6.3-11.el7.noarch.rpm                                                                        |  51 kB  00:00:00     
(2/4): firewalld-0.6.3-11.el7.noarch.rpm                                                                                   | 448 kB  00:00:00     
(3/4): nfs-utils-1.3.0-0.68.el7.x86_64.rpm                                                                                 | 412 kB  00:00:00     
(4/4): python-firewall-0.6.3-11.el7.noarch.rpm                                                                             | 355 kB  00:00:00     
--------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                             3.2 MB/s | 1.2 MB  00:00:00     
Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Importing GPG key 0xF4A80EB5:
 Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
 Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
 Package    : centos-release-7-8.2003.0.el7.centos.x86_64 (@anaconda)
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Updating   : firewalld-filesystem-0.6.3-11.el7.noarch                                                                                       1/8 
  Updating   : python-firewall-0.6.3-11.el7.noarch                                                                                            2/8 
  Updating   : firewalld-0.6.3-11.el7.noarch                                                                                                  3/8 
  Updating   : 1:nfs-utils-1.3.0-0.68.el7.x86_64                                                                                              4/8 
  Cleanup    : firewalld-0.6.3-8.el7_8.1.noarch                                                                                               5/8 
  Cleanup    : firewalld-filesystem-0.6.3-8.el7_8.1.noarch                                                                                    6/8 
  Cleanup    : python-firewall-0.6.3-8.el7_8.1.noarch                                                                                         7/8 
  Cleanup    : 1:nfs-utils-1.3.0-0.66.el7.x86_64                                                                                              8/8 
  Verifying  : python-firewall-0.6.3-11.el7.noarch                                                                                            1/8 
  Verifying  : firewalld-filesystem-0.6.3-11.el7.noarch                                                                                       2/8 
  Verifying  : firewalld-0.6.3-11.el7.noarch                                                                                                  3/8 
  Verifying  : 1:nfs-utils-1.3.0-0.68.el7.x86_64                                                                                              4/8 
  Verifying  : python-firewall-0.6.3-8.el7_8.1.noarch                                                                                         5/8 
  Verifying  : firewalld-0.6.3-8.el7_8.1.noarch                                                                                               6/8 
  Verifying  : firewalld-filesystem-0.6.3-8.el7_8.1.noarch                                                                                    7/8 
  Verifying  : 1:nfs-utils-1.3.0-0.66.el7.x86_64                                                                                              8/8 

Updated:
  firewalld.noarch 0:0.6.3-11.el7                                        nfs-utils.x86_64 1:1.3.0-0.68.el7                                       

Dependency Updated:
  firewalld-filesystem.noarch 0:0.6.3-11.el7                                 python-firewall.noarch 0:0.6.3-11.el7                                

Complete!
```
</details><br/>  
7. Запускаю необходимые сервисы, добавляю в автозагрузку.<br/>  
<details>
<summary>Вывод <code>[root@nfss ~]# systemctl enable firewalld    </code></summary>

```  
Created symlink from /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service to /usr/lib/systemd/system/firewalld.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/firewalld.service to /usr/lib/systemd/system/firewalld.service.
[root@nfss ~]# systemctl enable rpcbind
[root@nfss ~]# systemctl enable nfs-server
Created symlink from /etc/systemd/system/multi-user.target.wants/nfs-server.service to /usr/lib/systemd/system/nfs-server.service.
[root@nfss ~]# systemctl enable nfs-lock
[root@nfss ~]# systemctl enable nfs-idmap
[root@nfss ~]# systemctl start firewalld
[root@nfss ~]# systemctl start rpcbind
[root@nfss ~]# systemctl start nfs-server
[root@nfss ~]# systemctl start nfs-lock
[root@nfss ~]# systemctl start nfs-idmap
[root@nfss ~]# 
```
</details><br/>  
8. Создаю директорию будущей NFS-"шары", назначаю ей необходимые права.<br/>  
<details>
<summary>Вывод <code>[root@nfss ~]# mkdir /upload   </code></summary>

```  
[root@nfss ~]# chmod -R 0777 /upload
[root@nfss ~]# 
```
</details><br/>  
9. Добавляю в /etc/exports строку инициализации NFS-"шары".<br/>  
<details>
<summary>Вывод <code>[root@nfss ~]# echo "/upload 192.168.50.11(rw,sync,no_root_squash,no_all_squash)" > /etc/exports  </code></summary>

```  
[root@nfss ~]# cat /etc/exports
/upload 192.168.50.11(rw,sync,no_root_squash,no_all_squash)
```
</details><br/>  
10. Осуществляю экспорт директории, проверяю. <br/>  
<details>
<summary>Вывод <code>[root@nfss ~]# exportfs -r    </code></summary>

```  
[root@nfss ~]# showmount --exports
Export list for nfss:
/upload 192.168.50.11
[root@nfss ~]# 
```
</details><br/> 
11. Осуществляю настройку firewalld. <br/>  
<details>
<summary>Вывод <code>[root@nfss ~]# firewall-cmd --permanent --add-port=111/tcp     </code></summary>

```  
success
[root@nfss ~]# firewall-cmd --permanent --add-port=54302/tcp
success
[root@nfss ~]# firewall-cmd --permanent --add-port=20048/tcp
success
[root@nfss ~]# firewall-cmd --permanent --add-port=2049/tcp
success
[root@nfss ~]# firewall-cmd --permanent --add-port=46666/tcp
success
[root@nfss ~]# firewall-cmd --permanent --add-port=42955/tcp
success
[root@nfss ~]# firewall-cmd --permanent --add-port=875/tcp
success
[root@nfss ~]# firewall-cmd --permanent --add-port=111/udp
success
[root@nfss ~]# firewall-cmd --permanent --add-port=54302/udp
success
[root@nfss ~]# firewall-cmd --permanent --add-port=20048/udp
success
[root@nfss ~]# firewall-cmd --permanent --add-port=2049/udp
success
[root@nfss ~]# firewall-cmd --permanent --add-port=46666/udp
success
[root@nfss ~]# firewall-cmd --permanent --add-port=42955/udp
success
[root@nfss ~]# firewall-cmd --permanent --add-port=875/udp
success
[root@nfss ~]# firewall-cmd --permanent --zone=public --add-service=nfs
success
[root@nfss ~]# firewall-cmd --permanent --zone=public --add-service=mountd
success
[root@nfss ~]# firewall-cmd --permanent --zone=public --add-service=rpc-bind
success
[root@nfss ~]# firewall-cmd --reload
success
[root@nfss ~]# firewall-cmd --list-all
public (active)
  target: default
  icmp-block-inversion: no
  interfaces: eth0 eth1
  sources: 
  services: dhcpv6-client mountd nfs rpc-bind ssh
  ports: 111/tcp 54302/tcp 20048/tcp 2049/tcp 46666/tcp 42955/tcp 875/tcp 111/udp 54302/udp 20048/udp 2049/udp 46666/udp 42955/udp 875/udp
  protocols: 
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 
	
[root@nfss ~]# 
```
</details><br/> 
12. Приступаю к настройке NFS-клиента. <br/>  
<details>
<summary>Вывод <code>[root@nfss ~]# logout  </code></summary>

```  
[vagrant@nfss ~]$ logout
Connection to 127.0.0.1 closed.
[20:59:39] discentem@ws01]~/otus-task004/Centos7-NFS:
$> vagrant ssh nfsc
[vagrant@nfsc ~]$ sudo -i
[root@nfsc ~]# 
```
</details><br/> 
13. Устанавливаю необходимые пакеты NFS-сервиса, обновляю firewall. <br/>  
<details>
<summary>Вывод <code>[root@nfsc ~]# yum install -y nfs-utils nfs-utils-lib firewalld </code></summary>

```  
Failed to set locale, defaulting to C
Loaded plugins: fastestmirror
Determining fastest mirrors
 * base: mirror.axelname.ru
 * extras: mirror.axelname.ru
 * updates: mirror.axelname.ru
base                                                                                                                       | 3.6 kB  00:00:00     
extras                                                                                                                     | 2.9 kB  00:00:00     
updates                                                                                                                    | 2.9 kB  00:00:00     
(1/4): base/7/x86_64/group_gz                                                                                              | 153 kB  00:00:00     
(2/4): extras/7/x86_64/primary_db                                                                                          | 222 kB  00:00:00     
(3/4): base/7/x86_64/primary_db                                                                                            | 6.1 MB  00:00:01     
(4/4): updates/7/x86_64/primary_db                                                                                         | 2.5 MB  00:00:01     
No package nfs-utils-lib available.
Resolving Dependencies
--> Running transaction check
---> Package firewalld.noarch 0:0.6.3-8.el7_8.1 will be updated
---> Package firewalld.noarch 0:0.6.3-11.el7 will be an update
--> Processing Dependency: python-firewall = 0.6.3-11.el7 for package: firewalld-0.6.3-11.el7.noarch
--> Processing Dependency: firewalld-filesystem = 0.6.3-11.el7 for package: firewalld-0.6.3-11.el7.noarch
---> Package nfs-utils.x86_64 1:1.3.0-0.66.el7 will be updated
---> Package nfs-utils.x86_64 1:1.3.0-0.68.el7 will be an update
--> Running transaction check
---> Package firewalld-filesystem.noarch 0:0.6.3-8.el7_8.1 will be updated
---> Package firewalld-filesystem.noarch 0:0.6.3-11.el7 will be an update
---> Package python-firewall.noarch 0:0.6.3-8.el7_8.1 will be updated
---> Package python-firewall.noarch 0:0.6.3-11.el7 will be an update
--> Finished Dependency Resolution

Dependencies Resolved

==================================================================================================================================================
 Package                                    Arch                         Version                                 Repository                  Size
==================================================================================================================================================
Updating:
 firewalld                                  noarch                       0.6.3-11.el7                            base                       448 k
 nfs-utils                                  x86_64                       1:1.3.0-0.68.el7                        base                       412 k
Updating for dependencies:
 firewalld-filesystem                       noarch                       0.6.3-11.el7                            base                        51 k
 python-firewall                            noarch                       0.6.3-11.el7                            base                       355 k

Transaction Summary
==================================================================================================================================================
Upgrade  2 Packages (+2 Dependent packages)

Total download size: 1.2 M
Downloading packages:
No Presto metadata available for base
warning: /var/cache/yum/x86_64/7/base/packages/firewalld-filesystem-0.6.3-11.el7.noarch.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
Public key for firewalld-filesystem-0.6.3-11.el7.noarch.rpm is not installed
(1/4): firewalld-filesystem-0.6.3-11.el7.noarch.rpm                                                                        |  51 kB  00:00:00     
(2/4): nfs-utils-1.3.0-0.68.el7.x86_64.rpm                                                                                 | 412 kB  00:00:00     
(3/4): firewalld-0.6.3-11.el7.noarch.rpm                                                                                   | 448 kB  00:00:00     
(4/4): python-firewall-0.6.3-11.el7.noarch.rpm                                                                             | 355 kB  00:00:00     
--------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                             2.3 MB/s | 1.2 MB  00:00:00     
Retrieving key from file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Importing GPG key 0xF4A80EB5:
 Userid     : "CentOS-7 Key (CentOS 7 Official Signing Key) <security@centos.org>"
 Fingerprint: 6341 ab27 53d7 8a78 a7c2 7bb1 24c6 a8a7 f4a8 0eb5
 Package    : centos-release-7-8.2003.0.el7.centos.x86_64 (@anaconda)
 From       : /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Updating   : firewalld-filesystem-0.6.3-11.el7.noarch                                                                                       1/8 
  Updating   : python-firewall-0.6.3-11.el7.noarch                                                                                            2/8 
  Updating   : firewalld-0.6.3-11.el7.noarch                                                                                                  3/8 
  Updating   : 1:nfs-utils-1.3.0-0.68.el7.x86_64                                                                                              4/8 
  Cleanup    : firewalld-0.6.3-8.el7_8.1.noarch                                                                                               5/8 
  Cleanup    : firewalld-filesystem-0.6.3-8.el7_8.1.noarch                                                                                    6/8 
  Cleanup    : python-firewall-0.6.3-8.el7_8.1.noarch                                                                                         7/8 
  Cleanup    : 1:nfs-utils-1.3.0-0.66.el7.x86_64                                                                                              8/8 
  Verifying  : python-firewall-0.6.3-11.el7.noarch                                                                                            1/8 
  Verifying  : firewalld-filesystem-0.6.3-11.el7.noarch                                                                                       2/8 
  Verifying  : firewalld-0.6.3-11.el7.noarch                                                                                                  3/8 
  Verifying  : 1:nfs-utils-1.3.0-0.68.el7.x86_64                                                                                              4/8 
  Verifying  : python-firewall-0.6.3-8.el7_8.1.noarch                                                                                         5/8 
  Verifying  : firewalld-0.6.3-8.el7_8.1.noarch                                                                                               6/8 
  Verifying  : firewalld-filesystem-0.6.3-8.el7_8.1.noarch                                                                                    7/8 
  Verifying  : 1:nfs-utils-1.3.0-0.66.el7.x86_64                                                                                              8/8 

Updated:
  firewalld.noarch 0:0.6.3-11.el7                                        nfs-utils.x86_64 1:1.3.0-0.68.el7                                       

Dependency Updated:
  firewalld-filesystem.noarch 0:0.6.3-11.el7                                 python-firewall.noarch 0:0.6.3-11.el7                                

Complete!
[root@nfsc ~]# 
```
</details><br/> 
14.  Запускаю необходимые сервисы, добавляю в автозагрузку.<br/>  
<details>
<summary>Вывод <code>[root@nfsc ~]# systemctl enable firewalld    </code></summary>

```  
[root@nfsc ~]# systemctl enable firewalld
Created symlink from /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service to /usr/lib/systemd/system/firewalld.service.
Created symlink from /etc/systemd/system/multi-user.target.wants/firewalld.service to /usr/lib/systemd/system/firewalld.service.
[root@nfsc ~]# systemctl enable rpcbind
[root@nfsc ~]# systemctl enable nfs-server
Created symlink from /etc/systemd/system/multi-user.target.wants/nfs-server.service to /usr/lib/systemd/system/nfs-server.service.
[root@nfsc ~]# systemctl enable nfs-lock
[root@nfsc ~]# systemctl enable nfs-idmap
[root@nfsc ~]# systemctl start firewalld
[root@nfsc ~]# systemctl start rpcbind
[root@nfsc ~]# systemctl start nfs-server
[root@nfsc ~]# systemctl start nfs-lock
[root@nfsc ~]# systemctl start nfs-idmap
[root@nfsc ~]# 
```
</details><br/> 
15. Создаю директорию для монтирования NFS-"шары", назначаю ей необходимые права.<br/>  
<details>
<summary>Вывод <code>[root@nfsc ~]# mkdir -p /media/nfs_share  </code></summary>

```  
[root@nfsc ~]# chmod -R 0777 /media/nfs_share
[root@nfsc ~]# 
```
</details><br/> 
16. Осуществляю настройку firewalld. <br/>  
<details>
<summary>Вывод <code>[root@nfsc ~]# firewall-cmd --permanent --add-port=111/tcp     </code></summary>

```  
success
[root@nfsc ~]# firewall-cmd --permanent --add-port=54302/tcp
success
[root@nfsc ~]# firewall-cmd --permanent --add-port=20048/tcp
success
[root@nfsc ~]# firewall-cmd --permanent --add-port=2049/tcp
success
[root@nfsc ~]# firewall-cmd --permanent --add-port=46666/tcp
success
[root@nfsc ~]# firewall-cmd --permanent --add-port=42955/tcp
success
[root@nfsc ~]# firewall-cmd --permanent --add-port=875/tcp
success
[root@nfsc ~]# firewall-cmd --permanent --add-port=111/udp
success
[root@nfsc ~]# firewall-cmd --permanent --add-port=54302/udp
success
[root@nfsc ~]# firewall-cmd --permanent --add-port=20048/udp
success
[root@nfsc ~]# firewall-cmd --permanent --add-port=2049/udp
success
[root@nfsc ~]# firewall-cmd --permanent --add-port=46666/udp
success
[root@nfsc ~]# firewall-cmd --permanent --add-port=42955/udp
success
[root@nfsc ~]# firewall-cmd --permanent --add-port=875/udp
success
[root@nfsc ~]# firewall-cmd --permanent --zone=public --add-service=nfs
success
[root@nfsc ~]# firewall-cmd --permanent --zone=public --add-service=mountd
success
[root@nfsc ~]# firewall-cmd --permanent --zone=public --add-service=rpc-bind
success
[root@nfsc ~]# firewall-cmd --reload
success
[root@nfsc ~]# 
```
</details><br/> 
17. Монтирую NFS-"шару", проверяю. <br/>  
<details>
<summary>Вывод <code>[root@nfsc ~]# mount -t nfs -o proto=udp,vers=3  192.168.50.10:/upload /media/nfs_share   </code></summary>

```  
[root@nfsc ~]# df -h
Filesystem             Size  Used Avail Use% Mounted on
devtmpfs               111M     0  111M   0% /dev
tmpfs                  118M     0  118M   0% /dev/shm
tmpfs                  118M  4.6M  113M   4% /run
tmpfs                  118M     0  118M   0% /sys/fs/cgroup
/dev/sda1               40G  3.1G   37G   8% /
tmpfs                   24M     0   24M   0% /run/user/1000
tmpfs                   24M     0   24M   0% /run/user/0
192.168.50.10:/upload   40G  3.1G   37G   8% /media/nfs_share
[root@nfsc ~]# 
```
</details><br/> 
18. Закрпляю монтирования в /etc/fstab. <br/>  
<details>
<summary>Вывод <code>[root@nfsc ~]# echo "192.168.50.10:/upload /media/nfs_share nfs rw,vers=3,sync,proto=udp,rsize=32768,wsize=32768 0 0" >> /etc/fstab  </code></summary>

```  
[root@nfsc ~]# cat /etc/fstab

#
# /etc/fstab
# Created by anaconda on Thu Apr 30 22:04:55 2020
#
# Accessible filesystems, by reference, are maintained under '/dev/disk'
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
#
UUID=1c419d6c-5064-4a2b-953c-05b2c67edb15 /                       xfs     defaults        0 0
/swapfile none swap defaults 0 0
#VAGRANT-BEGIN
# The contents below are automatically generated by Vagrant. Do not modify.
#VAGRANT-END
192.168.50.10:/upload /media/nfs_share nfs rw,vers=3,sync,proto=udp,rsize=32768,wsize=32768 0 0
[root@nfsc ~]# 
```
</details><br/> 
19. Перезагружаю виртуальную машину NFS-клиента, проверяю. <br/>  
<details>
<summary>Вывод <code>[root@nfsc ~]# shutdown -r now </code></summary>

```  
Connection to 127.0.0.1 closed by remote host.
Connection to 127.0.0.1 closed.
[21:28:13] discentem@ws01]~/otus-task004/Centos7-NFS:
$> vagrant ssh nfsc
ssh_exchange_identification: read: Connection reset by peer
[21:28:26] discentem@ws01]~/otus-task004/Centos7-NFS:
$> vagrant ssh nfsc
Last login: Mon Nov 16 18:27:48 2020 from 10.0.2.2
[vagrant@nfsc ~]$ sudo -i
[root@nfsc ~]# df -h
Filesystem             Size  Used Avail Use% Mounted on
devtmpfs               111M     0  111M   0% /dev
tmpfs                  118M     0  118M   0% /dev/shm
tmpfs                  118M  4.5M  114M   4% /run
tmpfs                  118M     0  118M   0% /sys/fs/cgroup
/dev/sda1               40G  3.1G   37G   8% /
192.168.50.10:/upload   40G  3.1G   37G   8% /media/nfs_share
tmpfs                   24M     0   24M   0% /run/user/1000
[root@nfsc ~]# 
```
</details><br/>

NFS-"шара" монтируется.

## Проверка.
На основании выполненных команд формирую provision скрипты для Vagrantfile.  
Останавливаю запущенные ВМ, уничтожаю их. Снимаю комментарий в Vagrantfile c секций provision.  
Запускаю ВМ, проверяю выполнение.  




