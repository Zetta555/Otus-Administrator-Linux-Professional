# otus-task007
Управление пакетами. Дистрибьюция софта.  

## Собрать собственный rpm пакет и разместить его в собственном репозитории.  
[1. создать свой RPM (можно взять свое приложение, либо собрать к примеру апач с определенными опциями)](#createrpm)  

[2. создать свой репо и разместить там свой RPM реализовать это все либо в вагранте, либо развернуть у себя через nginx и дать ссылку на репо.](#createrepo)

## 1. Cоздать свой RPM.  <a name="createrpm"></a>

В качестве стенда используется ВМ развёрнутая средствами vagrant.  
<details><summary><code>$> cat Vagrantfile </code></summary>

```ruby
# -*- mode: ruby -*-
# vim: set ft=ruby :
home = ENV['HOME']
ENV["LC_ALL"] = "en_US.UTF-8"

MACHINES = {
  :vmrpm => {
        :box_name => "centos/7",
        :box_version => "1804.02",
        :ip_addr => '192.168.20.100',
#    :disks => {
#        :sata1 => {
#            :dfile => home + '/VirtualBox VMs/sata1.vdi',
#            :size => 1024,
#            :port => 1
#        },
#    }
  },
}

Vagrant.configure("2") do |config|

    config.vm.box_version = "1804.02"
    MACHINES.each do |boxname, boxconfig|
  
        config.vm.define boxname do |box|
  
            box.vm.box = boxconfig[:box_name]
            box.vm.host_name = boxname.to_s
  
            #box.vm.network "forwarded_port", guest: 3260, host: 3260+offset
  
            box.vm.network "private_network", ip: boxconfig[:ip_addr]
  
            box.vm.provider :virtualbox do |vb|
                    vb.customize ["modifyvm", :id, "--memory", "256"]
                    needsController = false
#            boxconfig[:disks].each do |dname, dconf|
#                unless File.exist?(dconf[:dfile])
#                  vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
#                                  needsController =  true
#                            end
#  
#            end
#                    if needsController == true
#                       vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
#                       boxconfig[:disks].each do |dname, dconf|
#                           vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
#                       end
#                    end
#            end
  
        box.vm.provision "shell", inline: <<-SHELL
            mkdir -p ~root/.ssh
            cp ~vagrant/.ssh/auth* ~root/.ssh
            yum install -y redhat-lsb-core wget gcc rpmdevtools rpm-build createrepo yum-utils mc
          SHELL
  
        end
    end
  end
end
  
```
</details> 

---------------------------------------
Скачиваю пакет исходников nginx.  
<code>[root@vmrpm ~]# wget https://nginx.org/packages/centos/7/SRPMS/nginx-1.18.0-2.el7.ngx.src.rpm</code>

---------------------------------------

Разворачиваю исходники из пакета.  
<code>[root@vmrpm ~]# rpm -i nginx-1.18.0-2.el7.ngx.src.rpm</code>

---------------------------------------

Скачиваю и распаковываю исходники openssl.  
<code>[root@vmrpm ~]# wget https://www.openssl.org/source/latest.tar.gz && tar -xvf latest.tar.gz</code>

---------------------------------------

Устанавливаю необходимые зависимости nginx.  
<code>[root@vmrpm ~]# yum-builddep -y rpmbuild/SPECS/nginx.spec</code>

---------------------------------------

Редактирую spec-файл, вношу изменения для сборки nginx с поддержкой SSL.  
<details><summary><code>[root@vmrpm ~]# vi rpmbuild/SPECS/nginx.spec</code></summary>
      
```shell
[root@vmrpm ~]# cat rpmbuild/SPECS/nginx.spec | grep with-openssl
    --with-openssl=/root/openssl-1.1.1h
```
</details> 

---------------------------------------

Осуществляю сборку пакета. Пакет собран корректно.
<details><summary><code>[root@vmrpm ~]# rpmbuild -bb rpmbuild/SPECS/nginx.spec</code></summary>
    
  ```shell
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd nginx-1.18.0
+ /usr/bin/rm -rf /root/rpmbuild/BUILDROOT/nginx-1.18.0-2.el7.ngx.x86_64
+ exit 0
  ```
</details> 

---------------------------------------

Просматриваю собранные пакеты.  
<details><summary><code>[root@vmrpm ~]# ls -lha rpmbuild/RPMS/x86_64/</code></summary>
    
  ```shell
total 3.8M
drwxr-xr-x. 2 root root   98 Nov 27 06:25 .
drwxr-xr-x. 3 root root   20 Nov 27 06:25 ..
-rw-r--r--. 1 root root 2.0M Nov 27 06:25 nginx-1.18.0-2.el7.ngx.x86_64.rpm
-rw-r--r--. 1 root root 1.9M Nov 27 06:25 nginx-debuginfo-1.18.0-2.el7.ngx.x86_64.rpm
  ```
</details> 

---------------------------------------

Проверяю доступность пакета nginx в подключенных репозиториях - отсутствует.  
<details><summary><code>[root@vmrpm ~]# yum provides nginx</code></summary>
  
  ```shell
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.docker.ru
 * extras: mirror.axelname.ru
 * updates: mirror.reconn.ru
base/7/x86_64/filelists_db                                                                                                 | 7.2 MB  00:00:01     
extras/7/x86_64/filelists_db                                                                                               | 224 kB  00:00:00     
updates/7/x86_64/filelists_db                                                                                              | 2.1 MB  00:00:00     
No matches found
```
</details> 

---------------------------------------

Устанавливаю nginx из собранного пакета
<details><summary><code>[root@vmrpm ~]# yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.18.0-2.el7.ngx.x86_64.rpm</code></summary>

```shell
Loaded plugins: fastestmirror
Examining rpmbuild/RPMS/x86_64/nginx-1.18.0-2.el7.ngx.x86_64.rpm: 1:nginx-1.18.0-2.el7.ngx.x86_64
Marking rpmbuild/RPMS/x86_64/nginx-1.18.0-2.el7.ngx.x86_64.rpm to be installed
Resolving Dependencies
--> Running transaction check
---> Package nginx.x86_64 1:1.18.0-2.el7.ngx will be installed
--> Finished Dependency Resolution

Dependencies Resolved

==================================================================================================================================================
 Package                  Arch                      Version                               Repository                                         Size
==================================================================================================================================================
Installing:
 nginx                    x86_64                    1:1.18.0-2.el7.ngx                    /nginx-1.18.0-2.el7.ngx.x86_64                    5.9 M

Transaction Summary
==================================================================================================================================================
Install  1 Package

Total size: 5.9 M
Installed size: 5.9 M
Downloading packages:
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : 1:nginx-1.18.0-2.el7.ngx.x86_64                                                                                                1/1 
----------------------------------------------------------------------

Thanks for using nginx!

Please find the official documentation for nginx here:
* http://nginx.org/en/docs/

Please subscribe to nginx-announce mailing list to get
the most important news about nginx:
* http://nginx.org/en/support.html

Commercial subscriptions for nginx are available on:
* http://nginx.com/products/

----------------------------------------------------------------------
  Verifying  : 1:nginx-1.18.0-2.el7.ngx.x86_64                                                                                                1/1 

Installed:
  nginx.x86_64 1:1.18.0-2.el7.ngx                                                                                                                 

Complete!
```
</details> 

---------------------------------------

Проверяю доступность пакета в репозиториях, репозиторий "installed" содержит локально установленные пакеты.  
<details><summary><code>[root@vmrpm ~]# yum provides nginx</code></summary>
  
```shell
  Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.docker.ru
 * extras: mirror.axelname.ru
 * updates: mirror.reconn.ru
1:nginx-1.18.0-2.el7.ngx.x86_64 : High performance web server
Repo        : installed
```
</details> 

---------------------------------------

## 2. Cоздать свой репозиторий.  <a name="createrepo"></a>

Создаю директорию в директории статического контента nginx.  
<summary><code>[root@vmrpm ~]# mkdir /usr/share/nginx/html/repo</code></summary>

---------------------------------------

В созданну директорию копирую собранный пакет nginx.  
<summary><code>[root@vmrpm ~]# cp rpmbuild/RPMS/x86_64/nginx-1.18.0-2.el7.ngx.x86_64.rpm /usr/share/nginx/html/repo/</code></summary>

---------------------------------------

В эту эе директорию скачиваю пакет percona.  
<summary><code>[root@vmrpm ~]# wget https://downloads.percona.com/downloads/percona-release/percona-release-1.0-9/redhat/percona-release-1.0-
9.noarch.rpm -O percona-release-1.0-9.noarch.rpm  /usr/share/nginx/html/repo/</code></summary>

---------------------------------------

Проверяю.  
<details><summary><code>[root@vmrpm ~]# ls -lha</code></summary>

```shell
total 2.0M
drwxr-xr-x. 2 root root   87 Nov 27 06:32 .
drwxr-xr-x. 3 root root   52 Nov 27 06:31 ..
-rw-r--r--. 1 root root 2.0M Nov 27 06:32 nginx-1.18.0-2.el7.ngx.x86_64.rpm
-rw-r--r--. 1 root root  17K Nov 11 21:49 percona-release-1.0-9.noarch.rpm

```
</details> 

---------------------------------------

Инициирую создание репозитория в данной директории.  
<details><summary><code>[root@vmrpm ~]# createrepo /usr/share/nginx/html/repo/</code></summary>

```shell
Spawning worker 0 with 2 pkgs
Workers Finished
Saving Primary metadata
Saving file lists metadata
Saving other metadata
Generating sqlite DBs
Sqlite DBs complete
```
</details> 

---------------------------------------

Проверяю.  
<details><summary><code>[root@vmrpm ~]# tree /usr/share/nginx/html/repo/</code></summary>

```shell
/usr/share/nginx/html/repo/
├── nginx-1.18.0-2.el7.ngx.x86_64.rpm
├── percona-release-1.0-9.noarch.rpm
└── repodata
    ├── 006e78b5e29732ae64fff8303dcf681f3a739182692b807b0385776944537c9a-filelists.sqlite.bz2
    ├── 264033d9230be0af090d7e247403ed84ad078fb26553d5302302766e367bbf3c-primary.xml.gz
    ├── 57f49da1443cea7aa56319ac540aa85c2b88a06ec0f97179b910268f0a21b832-filelists.xml.gz
    ├── 79257f819fd108ed83a6f5e16334696a5460076a41a2ad62dd2224b09b8c59e9-primary.sqlite.bz2
    ├── 852ce9bc274ba3272bf7f160ecc6d509ff279bfb85f4d53f3de4c1648a603249-other.xml.gz
    ├── afa4fa49d1345bd95be1a360fb804221a5fe1977ccf1ab056f798f77a736e203-other.sqlite.bz2
    └── repomd.xml

1 directory, 9 files

```
</details> 

---------------------------------------

Открываю листнинг статики.  
<details><summary><code>[root@vmrpm ~]# vi /etc/nginx/conf.d/default.conf</code></summary>

```shell
  location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
	      autoindex on;
    }
```
</details> 

---------------------------------------

Проверяю конфиг nginx.  
<details><summary><code>[root@vmrpm ~]# nginx -t</code></summary>

```shell
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```
</details> 

---------------------------------------

Включаю автозагузку.  
<details><summary><code>[root@vmrpm ~]# systemctl enable nginx</code></summary>

```shell
Created symlink from /etc/systemd/system/multi-user.target.wants/nginx.service to /usr/lib/systemd/system/nginx.service.
```
</details> 

---------------------------------------

Запускаю nginx.  
<code>[root@vmrpm ~]# systemctl start nginx</code>

---------------------------------------

Проверяю статус.  
<details><summary><code>[root@vmrpm ~]# systemctl status nginx</code></summary>

```shell
● nginx.service - nginx - high performance web server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; enabled; vendor preset: disabled)
   Active: active (running) since Fri 2020-11-27 06:37:25 UTC; 2s ago
     Docs: http://nginx.org/en/docs/
  Process: 19833 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf (code=exited, status=0/SUCCESS)
 Main PID: 19834 (nginx)
   CGroup: /system.slice/nginx.service
           ├─19834 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
           └─19835 nginx: worker process

Nov 27 06:37:25 vmrpm systemd[1]: Starting nginx - high performance web server...
Nov 27 06:37:25 vmrpm systemd[1]: PID file /var/run/nginx.pid not readable (yet?) after start.
Nov 27 06:37:25 vmrpm systemd[1]: Started nginx - high performance web server.
```
</details> 

---------------------------------------

Проверяю доступность контента.  
<details><summary><code>[root@vmrpm ~]# curl -a http://localhost/repo/</code></summary>

```shell
<html>
<head><title>Index of /repo/</title></head>
<body>
<h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
<a href="repodata/">repodata/</a>                                          27-Nov-2020 06:33                   -
<a href="nginx-1.18.0-2.el7.ngx.x86_64.rpm">nginx-1.18.0-2.el7.ngx.x86_64.rpm</a>                  27-Nov-2020 06:32             2018104
<a href="percona-release-1.0-9.noarch.rpm">percona-release-1.0-9.noarch.rpm</a>                   11-Nov-2020 21:49               16664
</pre><hr></body>
</html>
```
</details> 

---------------------------------------

Создаю repo-файл с информацией о созданном репозитории.  
<details><summary><code>[root@vmrpm ~]# cat >> /etc/yum.repos.d/otus.repo << EOF</code></summary>

```shell
> [otus]
> name=otus-linux
> baseurl=http://127.0.0.1/repo
> gpgcheck=0
> enabled=1
> EOF
```
</details> 

---------------------------------------

Проверяю доступность репозитория.  
<details><summary><code>[root@vmrpm ~]# yum repolist enabled | grep otus</code></summary>

```shell
otus                                otus-linux                                 2
```
</details> 

---------------------------------------

Проверяю доступные пакеты в созданном репозитории. информация о nginx в созданном репозитории отсутствует, 
<details><summary><code>[root@vmrpm ~]# yum list | grep otus</code></summary>

```shell
percona-release.noarch                      1.0-9                      otus     
```
</details> 

но содержит продублированную информацию.  
<details><summary><code>[root@vmrpm ~]# yum provides nginx</code></summary>

```shell
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.docker.ru
 * extras: mirror.axelname.ru
 * updates: mirror.reconn.ru
1:nginx-1.18.0-2.el7.ngx.x86_64 : High performance web server
Repo        : otus

1:nginx-1.18.0-2.el7.ngx.x86_64 : High performance web server
Repo        : installed

```
</details> 

---------------------------------------

Переустановлю nginx из доступного репозитория.  
<details><summary><code>[root@vmrpm ~]# yum reinstall nginx</code></summary>

```shell
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.docker.ru
 * extras: mirror.axelname.ru
 * updates: mirror.reconn.ru
Resolving Dependencies
--> Running transaction check
---> Package nginx.x86_64 1:1.18.0-2.el7.ngx will be reinstalled
--> Finished Dependency Resolution

Dependencies Resolved

==================================================================================================================================================
 Package                        Arch                            Version                                       Repository                     Size
==================================================================================================================================================
Reinstalling:
 nginx                          x86_64                          1:1.18.0-2.el7.ngx                            otus                          1.9 M

Transaction Summary
==================================================================================================================================================
Reinstall  1 Package

Total download size: 1.9 M
Installed size: 5.9 M
Is this ok [y/d/N]: y
Downloading packages:
nginx-1.18.0-2.el7.ngx.x86_64.rpm                                                                                          | 1.9 MB  00:00:00     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : 1:nginx-1.18.0-2.el7.ngx.x86_64                                                                                                1/1 
  Verifying  : 1:nginx-1.18.0-2.el7.ngx.x86_64                                                                                                1/1 

Installed:
  nginx.x86_64 1:1.18.0-2.el7.ngx                                                                                                                 

Complete!

```
</details> 

---------------------------------------

Теперь всё отлично - задание выполнено.  
<details><summary><code>[root@vmrpm ~]# yum list | grep otus</code></summary>
  
```shell
nginx.x86_64                                1:1.18.0-2.el7.ngx         @otus    
percona-release.noarch                      1.0-9                      otus     
```
</details>

---------------------------------------

