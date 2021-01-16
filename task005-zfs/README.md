# otus-task005
## Работа с ZFS

Для выполнения работы используется виртуальная машина с четырьмя дополнительно подключенными vhd  

<details><summary><code>$> cat Vagrantfile</code></summary>

```ruby
# -*- mode: ruby -*-
# vim: set ft=ruby :
home = ENV['HOME']
ENV["LC_ALL"] = "en_US.UTF-8"

MACHINES = {
  :zfs => {
        :box_name => "centos/7",
        :box_version => "2004.01",
        :ip_addr => '192.168.10.10',
    :disks => {
        :sata1 => {
            :dfile => home + '/VirtualBox VMs/sata1_zfs.vdi',
            :size => 1024,
            :port => 1
        },
        :sata2 => {
            :dfile => home + '/VirtualBox VMs/sata2_zfs.vdi',
            :size => 1024, # Megabytes
            :port => 2
        },
        :sata3 => {
            :dfile => home + '/VirtualBox VMs/sata3_zfs.vdi',
            :size => 1024, # Megabytes
            :port => 3
        },
        :sata4 => {
            :dfile => home + '/VirtualBox VMs/sata4_zfs.vdi',
            :size => 1024,
            :port => 4
        }
    }
  },
}

Vagrant.configure("2") do |config|

    config.vm.box_version = "2004.01"
    MACHINES.each do |boxname, boxconfig|
  
        config.vm.define boxname do |box|
  
            box.vm.box = boxconfig[:box_name]
            box.vm.host_name = boxname.to_s
  
            #box.vm.network "forwarded_port", guest: 3260, host: 3260+offset
  
            box.vm.network "private_network", ip: boxconfig[:ip_addr]
  
            box.vm.provider :virtualbox do |vb|
                    vb.customize ["modifyvm", :id, "--memory", "1024"]
                    needsController = false
            boxconfig[:disks].each do |dname, dconf|
                unless File.exist?(dconf[:dfile])
                  vb.customize ['createhd', '--filename', dconf[:dfile], '--variant', 'Fixed', '--size', dconf[:size]]
                                  needsController =  true
                            end
  
            end
                    if needsController == true
                       vb.customize ["storagectl", :id, "--name", "SATA", "--add", "sata" ]
                       boxconfig[:disks].each do |dname, dconf|
                           vb.customize ['storageattach', :id,  '--storagectl', 'SATA', '--port', dconf[:port], '--device', 0, '--type', 'hdd', '--medium', dconf[:dfile]]
                       end
                    end
            end
  
        box.vm.provision "shell", inline: <<-SHELL
            mkdir -p ~root/.ssh
            cp ~vagrant/.ssh/auth* ~root/.ssh
          SHELL
  
        end
    end
  end
```
</details>  

--------------------------------------------------------------------------------  

### Устанавливаю ZFS.
Предварительно устанавливаю дополнительные необходимые пакеты.  
<details><summary><code>[root@zfs ~]# yum install -y yum-utils wget tree</code></summary>

```shell
Loaded plugins: fastestmirror
Determining fastest mirrors
 * base: mirror.axelname.ru
 * extras: mirror.yandex.ru
 * updates: mirror.axelname.ru
base                                                                                                                       | 3.6 kB  00:00:00     
extras                                                                                                                     | 2.9 kB  00:00:00     
updates                                                                                                                    | 2.9 kB  00:00:00     
(1/4): base/7/x86_64/group_gz                                                                                              | 153 kB  00:00:00     
(2/4): extras/7/x86_64/primary_db                                                                                          | 222 kB  00:00:00     
(3/4): updates/7/x86_64/primary_db                                                                                         | 3.7 MB  00:00:00     
(4/4): base/7/x86_64/primary_db                                                                                            | 6.1 MB  00:00:01     
Resolving Dependencies
--> Running transaction check
---> Package tree.x86_64 0:1.6.0-10.el7 will be installed
---> Package wget.x86_64 0:1.14-18.el7_6.1 will be installed
---> Package yum-utils.noarch 0:1.1.31-53.el7 will be updated
---> Package yum-utils.noarch 0:1.1.31-54.el7_8 will be an update
--> Finished Dependency Resolution

Dependencies Resolved

==================================================================================================================================================
 Package                            Arch                            Version                                   Repository                     Size
==================================================================================================================================================
Installing:
 tree                               x86_64                          1.6.0-10.el7                              base                           46 k
 wget                               x86_64                          1.14-18.el7_6.1                           base                          547 k
Updating:
 yum-utils                          noarch                          1.1.31-54.el7_8                           base                          122 k

Transaction Summary
==================================================================================================================================================
Install  2 Packages
Upgrade  1 Package

Total download size: 715 k
Downloading packages:
No Presto metadata available for base
warning: /var/cache/yum/x86_64/7/base/packages/tree-1.6.0-10.el7.x86_64.rpm: Header V3 RSA/SHA256 Signature, key ID f4a80eb5: NOKEY
Public key for tree-1.6.0-10.el7.x86_64.rpm is not installed
(1/3): tree-1.6.0-10.el7.x86_64.rpm                                                                                        |  46 kB  00:00:00     
(2/3): yum-utils-1.1.31-54.el7_8.noarch.rpm                                                                                | 122 kB  00:00:00     
(3/3): wget-1.14-18.el7_6.1.x86_64.rpm                                                                                     | 547 kB  00:00:00     
--------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                             2.4 MB/s | 715 kB  00:00:00     
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
  Installing : wget-^[[B1.14-18.el7_6.1.x86_64 [############################################################################################### ]   Installing : wget-1.14-18.el7_6.1.x86_64                                                                                                    1/4 
  Updating   : yum-utils-1.1.31-54.el7_8.noarch                                                                                               2/4 
  Installing : tree-1.6.0-10.el7.x86_64                                                                                                       3/4 
  Cleanup    : yum-utils-1.1.31-53.el7.noarch                                                                                                 4/4 
  Verifying  : tree-1.6.0-10.el7.x86_64                                                                                                       1/4 
  Verifying  : yum-utils-1.1.31-54.el7_8.noarch                                                                                               2/4 
  Verifying  : wget-1.14-18.el7_6.1.x86_64                                                                                                    3/4 
  Verifying  : yum-utils-1.1.31-53.el7.noarch                                                                                                 4/4 

Installed:
  tree.x86_64 0:1.6.0-10.el7                                             wget.x86_64 0:1.14-18.el7_6.1                                            

Updated:
  yum-utils.noarch 0:1.1.31-54.el7_8                                                                                                              

Complete!

```
</details>  

--------------------------------------------------------------------------------

Уточняю версию установленной системы.  
<details><summary><code>[root@zfs ~]# cat /etc/centos-release </code></summary>

```shell
CentOS Linux release 7.8.2003 (Core)
```
</details>  

--------------------------------------------------------------------------------

Устанавливаю репозиторий ZFS, соответствующий нашей системе.  
<details><summary><code>[root@zfs ~]# yum install -y http://download.zfsonlinux.org/epel/zfs-release.el7_8.noarch.rpm </code></summary>
  
```shell
Loaded plugins: fastestmirror
zfs-release.el7_8.noarch.rpm                                                                                               | 5.3 kB  00:00:00     
Examining /var/tmp/yum-root-D2GBI0/zfs-release.el7_8.noarch.rpm: zfs-release-1-7.8.noarch
Marking /var/tmp/yum-root-D2GBI0/zfs-release.el7_8.noarch.rpm to be installed
Resolving Dependencies
--> Running transaction check
---> Package zfs-release.noarch 0:1-7.8 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

==================================================================================================================================================
 Package                           Arch                         Version                     Repository                                       Size
==================================================================================================================================================
Installing:
 zfs-release                       noarch                       1-7.8                       /zfs-release.el7_8.noarch                       2.9 k

Transaction Summary
==================================================================================================================================================
Install  1 Package

Total size: 2.9 k
Installed size: 2.9 k
Downloading packages:
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : zfs-release-1-7.8.noarch                                                                                                       1/1 
  Verifying  : zfs-release-1-7.8.noarch                                                                                                       1/1 

Installed:
  zfs-release.noarch 0:1-7.8                                                                                                                      

Complete!
```
</details>  

--------------------------------------------------------------------------------

Устанавливаю открытый ключ.
<details><summary><code>[root@zfs ~]# gpg --quiet --with-fingerprint /etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux</code></summary>
  
```shell
gpg: new configuration file `/root/.gnupg/gpg.conf' created
gpg: WARNING: options in `/root/.gnupg/gpg.conf' are not yet active during this run
pub  2048R/F14AB620 2013-03-21 ZFS on Linux <zfs@zfsonlinux.org>
      Key fingerprint = C93A FFFD 9F3F 7B03 C310  CEB6 A9D5 A1C0 F14A B620
sub  2048R/99685629 2013-03-21
```
</details>  

--------------------------------------------------------------------------------

Проверяю обновлённый список репозиториев.
<details><summary><code>[root@zfs ~]# yum repolist</code></summary>
  
```shell
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.axelname.ru
 * extras: mirror.yandex.ru
 * updates: mirror.axelname.ru
zfs                                                                                                                        | 2.9 kB  00:00:00     
zfs/x86_64/primary_db                                                                                                      |  18 kB  00:00:00     
repo id                                                         repo name                                                                   status
base/7/x86_64                                                   CentOS-7 - Base                                                             10,072
extras/7/x86_64                                                 CentOS-7 - Extras                                                              448
updates/7/x86_64                                                CentOS-7 - Updates                                                             773
zfs/x86_64                                                      ZFS on Linux for EL7 - dkms                                                     22
repolist: 11,315
```
</details>  

--------------------------------------------------------------------------------

Включаю репозиторий с [kmod](https://openzfs.github.io/openzfs-docs/Getting%20Started/RHEL%20and%20CentOS.html#kabi-tracking-kmod "kABI-tracking kmod")
<details><summary><code>[root@zfs ~]# yum-config-manager --enable zfs-kmod</code></summary>
  
```shell  
Loaded plugins: fastestmirror
================================================================= repo: zfs-kmod =================================================================
[zfs-kmod]
async = True
bandwidth = 0
base_persistdir = /var/lib/yum/repos/x86_64/7
baseurl = http://download.zfsonlinux.org/epel/7.8/kmod/x86_64/
cache = 0
cachedir = /var/cache/yum/x86_64/7/zfs-kmod
check_config_file_age = True
compare_providers_priority = 80
cost = 1000
deltarpm_metadata_percentage = 100
deltarpm_percentage = 
enabled = 1
enablegroups = True
exclude = 
failovermethod = priority
ftp_disable_epsv = False
gpgcadir = /var/lib/yum/repos/x86_64/7/zfs-kmod/gpgcadir
gpgcakey = 
gpgcheck = True
gpgdir = /var/lib/yum/repos/x86_64/7/zfs-kmod/gpgdir
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
hdrdir = /var/cache/yum/x86_64/7/zfs-kmod/headers
http_caching = all
includepkgs = 
ip_resolve = 
keepalive = True
keepcache = False
mddownloadpolicy = sqlite
mdpolicy = group:small
mediaid = 
metadata_expire = 604800
metadata_expire_filter = read-only:present
metalink = 
minrate = 0
mirrorlist = 
mirrorlist_expire = 86400
name = ZFS on Linux for EL7 - kmod
old_base_cache_dir = 
password = 
persistdir = /var/lib/yum/repos/x86_64/7/zfs-kmod
pkgdir = /var/cache/yum/x86_64/7/zfs-kmod/packages
proxy = False
proxy_dict = 
proxy_password = 
proxy_username = 
repo_gpgcheck = False
retries = 10
skip_if_unavailable = False
ssl_check_cert_permissions = True
sslcacert = 
sslclientcert = 
sslclientkey = 
sslverify = True
throttle = 0
timeout = 30.0
ui_id = zfs-kmod/x86_64
ui_repoid_vars = releasever,
   basearch
username = 
```
</details>  

--------------------------------------------------------------------------------

Проверяю репозитории.
<details><summary><code>[root@zfs ~]# yum repolist</code></summary>
  
```shell
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.axelname.ru
 * extras: mirror.yandex.ru
 * updates: mirror.axelname.ru
zfs                                                                                                                        | 2.9 kB  00:00:00     
zfs-kmod                                                                                                                   | 2.9 kB  00:00:00     
zfs-kmod/x86_64/primary_db                                                                                                 |  82 kB  00:00:00     
repo id                                                         repo name                                                                   status
base/7/x86_64                                                   CentOS-7 - Base                                                             10,072
extras/7/x86_64                                                 CentOS-7 - Extras                                                              448
updates/7/x86_64                                                CentOS-7 - Updates                                                             773
zfs/x86_64                                                      ZFS on Linux for EL7 - dkms                                                     22
zfs-kmod/x86_64                                                 ZFS on Linux for EL7 - kmod                                                     26
repolist: 11,341
```
</details>  

--------------------------------------------------------------------------------

Отключаю репозиторий [dkms](https://openzfs.github.io/openzfs-docs/Getting%20Started/RHEL%20and%20CentOS.html#dkms)
<details><summary><code>[root@zfs ~]# yum-config-manager --disable zfs</code></summary>
  
```shell
Loaded plugins: fastestmirror
=================================================================== repo: zfs ====================================================================
[zfs]
async = True
bandwidth = 0
base_persistdir = /var/lib/yum/repos/x86_64/7
baseurl = http://download.zfsonlinux.org/epel/7.8/x86_64/
cache = 0
cachedir = /var/cache/yum/x86_64/7/zfs
check_config_file_age = True
compare_providers_priority = 80
cost = 1000
deltarpm_metadata_percentage = 100
deltarpm_percentage = 
enabled = 0
enablegroups = True
exclude = 
failovermethod = priority
ftp_disable_epsv = False
gpgcadir = /var/lib/yum/repos/x86_64/7/zfs/gpgcadir
gpgcakey = 
gpgcheck = True
gpgdir = /var/lib/yum/repos/x86_64/7/zfs/gpgdir
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-zfsonlinux
hdrdir = /var/cache/yum/x86_64/7/zfs/headers
http_caching = all
includepkgs = 
ip_resolve = 
keepalive = True
keepcache = False
mddownloadpolicy = sqlite
mdpolicy = group:small
mediaid = 
metadata_expire = 604800
metadata_expire_filter = read-only:present
metalink = 
minrate = 0
mirrorlist = 
mirrorlist_expire = 86400
name = ZFS on Linux for EL7 - dkms
old_base_cache_dir = 
password = 
persistdir = /var/lib/yum/repos/x86_64/7/zfs
pkgdir = /var/cache/yum/x86_64/7/zfs/packages
proxy = False
proxy_dict = 
proxy_password = 
proxy_username = 
repo_gpgcheck = False
retries = 10
skip_if_unavailable = False
ssl_check_cert_permissions = True
sslcacert = 
sslclientcert = 
sslclientkey = 
sslverify = True
throttle = 0
timeout = 30.0
ui_id = zfs/x86_64
ui_repoid_vars = releasever,
   basearch
username = 
```
</details>  

--------------------------------------------------------------------------------
Вновь проверяю список реп.
<details><summary><code>[root@zfs ~]# yum repolist</code></summary>
  
```shell
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.axelname.ru
 * extras: mirror.yandex.ru
 * updates: mirror.axelname.ru
repo id                                                         repo name                                                                   status
base/7/x86_64                                                   CentOS-7 - Base                                                             10,072
extras/7/x86_64                                                 CentOS-7 - Extras                                                              448
updates/7/x86_64                                                CentOS-7 - Updates                                                             773
zfs-kmod/x86_64                                                 ZFS on Linux for EL7 - kmod                                                     26
repolist: 11,319
```
</details>  

--------------------------------------------------------------------------------

Устанавливаю zfs.
<details><summary><code>[root@zfs ~]# yum install -y zfs</code></summary>
  
```shell
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: mirror.axelname.ru
 * extras: mirror.yandex.ru
 * updates: mirror.axelname.ru
zfs-kmod                                                                                                                   | 2.9 kB  00:00:00     
Resolving Dependencies
--> Running transaction check
---> Package zfs.x86_64 0:0.8.5-1.el7 will be installed
--> Processing Dependency: zfs-kmod = 0.8.5 for package: zfs-0.8.5-1.el7.x86_64
--> Processing Dependency: libzpool2 = 0.8.5 for package: zfs-0.8.5-1.el7.x86_64
--> Processing Dependency: libzfs2 = 0.8.5 for package: zfs-0.8.5-1.el7.x86_64
--> Processing Dependency: libuutil1 = 0.8.5 for package: zfs-0.8.5-1.el7.x86_64
--> Processing Dependency: libnvpair1 = 0.8.5 for package: zfs-0.8.5-1.el7.x86_64
--> Processing Dependency: sysstat for package: zfs-0.8.5-1.el7.x86_64
--> Processing Dependency: libzpool.so.2()(64bit) for package: zfs-0.8.5-1.el7.x86_64
--> Processing Dependency: libzfs_core.so.1()(64bit) for package: zfs-0.8.5-1.el7.x86_64
--> Processing Dependency: libzfs.so.2()(64bit) for package: zfs-0.8.5-1.el7.x86_64
--> Processing Dependency: libuutil.so.1()(64bit) for package: zfs-0.8.5-1.el7.x86_64
--> Processing Dependency: libnvpair.so.1()(64bit) for package: zfs-0.8.5-1.el7.x86_64
--> Running transaction check
---> Package kmod-zfs.x86_64 0:0.8.5-1.el7 will be installed
---> Package libnvpair1.x86_64 0:0.8.5-1.el7 will be installed
---> Package libuutil1.x86_64 0:0.8.5-1.el7 will be installed
---> Package libzfs2.x86_64 0:0.8.5-1.el7 will be installed
---> Package libzpool2.x86_64 0:0.8.5-1.el7 will be installed
---> Package sysstat.x86_64 0:10.1.5-19.el7 will be installed
--> Processing Dependency: libsensors.so.4()(64bit) for package: sysstat-10.1.5-19.el7.x86_64
--> Running transaction check
---> Package lm_sensors-libs.x86_64 0:3.4.0-8.20160601gitf9185e5.el7 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

==================================================================================================================================================
 Package                            Arch                      Version                                           Repository                   Size
==================================================================================================================================================
Installing:
 zfs                                x86_64                    0.8.5-1.el7                                       zfs-kmod                    486 k
Installing for dependencies:
 kmod-zfs                           x86_64                    0.8.5-1.el7                                       zfs-kmod                    1.1 M
 libnvpair1                         x86_64                    0.8.5-1.el7                                       zfs-kmod                     32 k
 libuutil1                          x86_64                    0.8.5-1.el7                                       zfs-kmod                     26 k
 libzfs2                            x86_64                    0.8.5-1.el7                                       zfs-kmod                    208 k
 libzpool2                          x86_64                    0.8.5-1.el7                                       zfs-kmod                    861 k
 lm_sensors-libs                    x86_64                    3.4.0-8.20160601gitf9185e5.el7                    base                         42 k
 sysstat                            x86_64                    10.1.5-19.el7                                     base                        315 k

Transaction Summary
==================================================================================================================================================
Install  1 Package (+7 Dependent packages)

Total download size: 3.0 M
Installed size: 11 M
Downloading packages:
(1/8): libnvpair1-0.8.5-1.el7.x86_64.rpm                                                                                   |  32 kB  00:00:00     
(2/8): libuutil1-0.8.5-1.el7.x86_64.rpm                                                                                    |  26 kB  00:00:00     
(3/8): libzfs2-0.8.5-1.el7.x86_64.rpm                                                                                      | 208 kB  00:00:00     
(4/8): kmod-zfs-0.8.5-1.el7.x86_64.rpm                                                                                     | 1.1 MB  00:00:01     
(5/8): lm_sensors-libs-3.4.0-8.20160601gitf9185e5.el7.x86_64.rpm                                                           |  42 kB  00:00:00     
(6/8): sysstat-10.1.5-19.el7.x86_64.rpm                                                                                    | 315 kB  00:00:00     
(7/8): libzpool2-0.8.5-1.el7.x86_64.rpm                                                                                    | 861 kB  00:00:00     
(8/8): zfs-0.8.5-1.el7.x86_64.rpm                                                                                          | 486 kB  00:00:02     
--------------------------------------------------------------------------------------------------------------------------------------------------
Total                                                                                                             699 kB/s | 3.0 MB  00:00:04     
Running transaction check
Running transaction test
Transaction test succeeded
Running transaction
  Installing : libnvpair1-0.8.5-1.el7.x86_64                                                                                                  1/8 
  Installing : libuutil1-0.8.5-1.el7.x86_64                                                                                                   2/8 
  Installing : libzfs2-0.8.5-1.el7.x86_64                                                                                                     3/8 
  Installing : libzpool2-0.8.5-1.el7.x86_64                                                                                                   4/8 
  Installing : lm_sensors-libs-3.4.0-8.20160601gitf9185e5.el7.x86_64                                                                          5/8 
  Installing : sysstat-10.1.5-19.el7.x86_64                                                                                                   6/8 
  Installing : kmod-zfs-0.8.5-1.el7.x86_64                                                                                                    7/8 
  Installing : zfs-0.8.5-1.el7.x86_64                                                                                                         8/8 
  Verifying  : sysstat-10.1.5-19.el7.x86_64                                                                                                   1/8 
  Verifying  : libuutil1-0.8.5-1.el7.x86_64                                                                                                   2/8 
  Verifying  : libzfs2-0.8.5-1.el7.x86_64                                                                                                     3/8 
  Verifying  : zfs-0.8.5-1.el7.x86_64                                                                                                         4/8 
  Verifying  : kmod-zfs-0.8.5-1.el7.x86_64                                                                                                    5/8 
  Verifying  : libnvpair1-0.8.5-1.el7.x86_64                                                                                                  6/8 
  Verifying  : lm_sensors-libs-3.4.0-8.20160601gitf9185e5.el7.x86_64                                                                          7/8 
  Verifying  : libzpool2-0.8.5-1.el7.x86_64                                                                                                   8/8 

Installed:
  zfs.x86_64 0:0.8.5-1.el7                                                                                                                        

Dependency Installed:
  kmod-zfs.x86_64 0:0.8.5-1.el7          libnvpair1.x86_64 0:0.8.5-1.el7         libuutil1.x86_64 0:0.8.5-1.el7                                 
  libzfs2.x86_64 0:0.8.5-1.el7           libzpool2.x86_64 0:0.8.5-1.el7          lm_sensors-libs.x86_64 0:3.4.0-8.20160601gitf9185e5.el7        
  sysstat.x86_64 0:10.1.5-19.el7        

Complete!
```
</details>  

--------------------------------------------------------------------------------

Подключаю установленный модуль ядра.  
<code>[root@zfs ~]# modprobe zfs</code>

--------------------------------------------------------------------------------

Проверяю.
<details><summary><code>[root@zfs ~]# zfs version</code></summary>
  
```shell
zfs-0.8.5-1
zfs-kmod-0.8.5-1
```
</details>  
Готово. Можно работать с ZFS.

--------------------------------------------------------------------------------

## 1. Определить алгоритм с наилучшим сжатием.  

Уточняю вводные: наличие свободных блочных устройств.
<details><summary><code>[root@zfs ~]# lsblk</code></summary>
  
```shell
NAME   MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
sda      8:0    0  40G  0 disk 
└─sda1   8:1    0  40G  0 part /
sdb      8:16   0   1G  0 disk 
sdc      8:32   0   1G  0 disk 
sdd      8:48   0   1G  0 disk 
sde      8:64   0   1G  0 disk 
```
</details> 
 
--------------------------------------------------------------------------------

Создаю на 4-х свободных дисках пул zfs в виде raidz1, примерный аналог RAID5, требует минимум 3 дисков, объем одного диска уходит на избыточность. Выдерживает смерть одного любого диска.
<details><summary><code>[root@zfs ~]# zpool create zfsraid raidz1 /dev/sd[b-e]</code></summary>
  
```shell
```
</details> 
 
--------------------------------------------------------------------------------

Проверяю.
<details><summary><code>[root@zfs ~]# zpool list</code></summary>
  
```shell
NAME      SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
zfsraid  3.75G   161K  3.75G        -         -     0%     0%  1.00x    ONLINE  -

[root@zfs ~]# zpool status
  pool: zfsraid
 state: ONLINE
  scan: none requested
config:

	NAME        STATE     READ WRITE CKSUM
	zfsraid     ONLINE       0     0     0
	  raidz1-0  ONLINE       0     0     0
	    sdb     ONLINE       0     0     0
	    sdc     ONLINE       0     0     0
	    sdd     ONLINE       0     0     0
	    sde     ONLINE       0     0     0

errors: No known data errors

[root@zfs ~]# df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        489M     0  489M   0% /dev
tmpfs           496M     0  496M   0% /dev/shm
tmpfs           496M  6.7M  489M   2% /run
tmpfs           496M     0  496M   0% /sys/fs/cgroup
/dev/sda1        40G  3.1G   37G   8% /
tmpfs           100M     0  100M   0% /run/user/1000
zfsraid         2.7G  128K  2.7G   1% /zfsraid

[root@zfs ~]# lsblk
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   40G  0 disk 
└─sda1   8:1    0   40G  0 part /
sdb      8:16   0    1G  0 disk 
├─sdb1   8:17   0 1014M  0 part 
└─sdb9   8:25   0    8M  0 part 
sdc      8:32   0    1G  0 disk 
├─sdc1   8:33   0 1014M  0 part 
└─sdc9   8:41   0    8M  0 part 
sdd      8:48   0    1G  0 disk 
├─sdd1   8:49   0 1014M  0 part 
└─sdd9   8:57   0    8M  0 part 
sde      8:64   0    1G  0 disk 
├─sde1   8:65   0 1014M  0 part 
└─sde9   8:73   0    8M  0 part 
```
</details> 
 
--------------------------------------------------------------------------------

Создаю 4 раздела.
<details><summary><code>[root@zfs ~]# zfs create zfsraid/fs1</code></summary>
  
```shell
[root@zfs ~]# zfs create zfsraid/fs2
[root@zfs ~]# zfs create zfsraid/fs3
[root@zfs ~]# zfs create zfsraid/fs4
```
</details> 
 
--------------------------------------------------------------------------------

Проверяю.
<details><summary><code>[root@zfs ~]# zfs list</code></summary>
  
```shell
NAME          USED  AVAIL     REFER  MOUNTPOINT
zfsraid       275K  2.68G     37.4K  /zfsraid
zfsraid/fs1  32.9K  2.68G     32.9K  /zfsraid/fs1
zfsraid/fs2  32.9K  2.68G     32.9K  /zfsraid/fs2
zfsraid/fs3  32.9K  2.68G     32.9K  /zfsraid/fs3
zfsraid/fs4  32.9K  2.68G     32.9K  /zfsraid/fs4
```
</details> 
 
--------------------------------------------------------------------------------

Рассматриваю используемые методы сжатия - не применены.
<details><summary><code>[root@zfs ~]# zfs get compression zfsraid/fs1</code></summary>
  
```shell
NAME         PROPERTY     VALUE     SOURCE
zfsraid/fs1  compression  off       default
[root@zfs ~]# zfs get compression zfsraid/fs3
NAME         PROPERTY     VALUE     SOURCE
zfsraid/fs3  compression  off       default
```
</details> 
 
--------------------------------------------------------------------------------

Применяю для 1-го раздела метод сжатия lzjb
<details><summary><code>[root@zfs ~]# zfs set compression=lzjb zfsraid/fs1</code></summary>
  
```shell
[root@zfs ~]# zfs get compression zfsraid/fs1
NAME         PROPERTY     VALUE     SOURCE
zfsraid/fs1  compression  lzjb      local
```
</details> 
 
--------------------------------------------------------------------------------

Применяю для 2-го раздела метод сжатия gzip-9
<details><summary><code>[root@zfs ~]# zfs set compression=gzip-9 zfsraid/fs2</code></summary>
  
```shell
[root@zfs ~]# zfs get compression zfsraid/fs2
NAME         PROPERTY     VALUE     SOURCE
zfsraid/fs2  compression  gzip-9    local
```
</details> 
 
--------------------------------------------------------------------------------

Применяю для 3-го раздела метод сжатия zle
<details><summary><code>[root@zfs ~]# zfs set compression=zle zfsraid/fs3</code></summary>
  
```shell
[root@zfs ~]# zfs get compression zfsraid/fs3
NAME         PROPERTY     VALUE     SOURCE
zfsraid/fs3  compression  zle       local
```
</details> 
 
--------------------------------------------------------------------------------

Применяю для 4-го раздела метод сжатия lz4
<details><summary><code>[root@zfs ~]# zfs set compression=lz4 zfsraid/fs4</code></summary>
  
```shell
[root@zfs ~]# zfs get compression zfsraid/fs4
NAME         PROPERTY     VALUE     SOURCE
zfsraid/fs4  compression  lz4       local
```
</details> 
 
--------------------------------------------------------------------------------

Скачиваю текстовый файл.
<details><summary><code>[root@zfs ~]# wget -O War_and_Peace.txt http://www.gutenberg.org/ebooks/2600.txt.utf-8</code></summary>
  
```shell
--2020-11-19 16:56:04--  http://www.gutenberg.org/ebooks/2600.txt.utf-8
Resolving www.gutenberg.org (www.gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to www.gutenberg.org (www.gutenberg.org)|152.19.134.47|:80... connected.
HTTP request sent, awaiting response... 302 Found
Location: http://www.gutenberg.org/cache/epub/2600/pg2600.txt [following]
--2020-11-19 16:56:04--  http://www.gutenberg.org/cache/epub/2600/pg2600.txt
Reusing existing connection to www.gutenberg.org:80.
HTTP request sent, awaiting response... 200 OK
Length: 1209374 (1.2M) [text/plain]
Saving to: ‘War_and_Peace.txt’

100%[========================================================================================================>] 1,209,374   1.01MB/s   in 1.1s   

2020-11-19 16:56:06 (1.01 MB/s) - ‘War_and_Peace.txt’ saved [1209374/1209374]

[root@zfs ~]# ls -lha
total 1.2M
dr-xr-x---.  4 root root  188 Nov 19 16:56 .
dr-xr-xr-x. 19 root root  270 Nov 19 16:49 ..
-rw-------.  1 root root 5.5K Apr 30  2020 anaconda-ks.cfg
-rw-r--r--.  1 root root   18 Dec 29  2013 .bash_logout
-rw-r--r--.  1 root root  176 Dec 29  2013 .bash_profile
-rw-r--r--.  1 root root  176 Dec 29  2013 .bashrc
-rw-r--r--.  1 root root  100 Dec 29  2013 .cshrc
drwx------.  2 root root   60 Nov 19 16:42 .gnupg
-rw-------.  1 root root 5.2K Apr 30  2020 original-ks.cfg
drwxr-xr-x.  2 root root   29 Nov 19 16:40 .ssh
-rw-r--r--.  1 root root  129 Dec 29  2013 .tcshrc
-rw-r--r--.  1 root root 1.2M May  6  2016 War_and_Peace.txt
```
</details> 
 
--------------------------------------------------------------------------------

Копирую полученный текстовик по разделам.
<details><summary><code>[root@zfs ~]# cp War_and_Peace.txt /zfsraid/fs1</code></summary>
  
```shell
[root@zfs ~]# cp War_and_Peace.txt /zfsraid/fs2
[root@zfs ~]# cp War_and_Peace.txt /zfsraid/fs3
[root@zfs ~]# cp War_and_Peace.txt /zfsraid/fs4
```
</details> 
 
--------------------------------------------------------------------------------

Проверяю степень сжатия по разделам
<details><summary><code>[root@zfs ~]# zfs get compressratio /zfsraid/fs{1..4}</code></summary>
  
```shell
NAME         PROPERTY       VALUE  SOURCE
zfsraid/fs1  compressratio  1.07x  -
zfsraid/fs2  compressratio  1.08x  -
zfsraid/fs3  compressratio  1.08x  -
zfsraid/fs4  compressratio  1.08x  -
```
</details> 
  
--------------------------------------------------------------------------------

метод сжатия lzjb чуть меньше остальных
<details><summary><code>[root@zfs ~]# zfs get compression zfsraid/fs{1..4}</code></summary>
  
```shell
NAME         PROPERTY     VALUE     SOURCE
zfsraid/fs1  compression  lzjb      local
zfsraid/fs2  compression  gzip-9    local
zfsraid/fs3  compression  zle       local
zfsraid/fs4  compression  lz4       local
```
</details> 
  
--------------------------------------------------------------------------------

## 2. Определить настройки pool’a.

Скачиваю предварительно экспортированный pool.
<details><summary><code>[root@zfs ~]# wget --no-check-certificate -r "https://docs.google.com/uc?export=download&id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg" -O zfs_task1.tar.gz</code></summary>
  
```shell
WARNING: combining -O with -r or -p will mean that all downloaded content
will be placed in the single file you specified.

--2020-11-19 17:01:24--  https://docs.google.com/uc?export=download&id=1KRBNW33QWqbvbVHa3hLJivOAt60yukkg
Resolving docs.google.com (docs.google.com)... 64.233.163.194, 2a00:1450:4010:c01::c2
Connecting to docs.google.com (docs.google.com)|64.233.163.194|:443... connected.
HTTP request sent, awaiting response... 302 Moved Temporarily
Location: https://doc-0c-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/f664klu8uek1ai3hscfb3q27io3fndmq/1605805275000/16189157874053420687/*/1KRBNW33QWqbvbVHa3hLJivOAt60yukkg?e=download [following]
Warning: wildcards not supported in HTTP.
--2020-11-19 17:01:33--  https://doc-0c-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/f664klu8uek1ai3hscfb3q27io3fndmq/1605805275000/16189157874053420687/*/1KRBNW33QWqbvbVHa3hLJivOAt60yukkg?e=download
Resolving doc-0c-bo-docs.googleusercontent.com (doc-0c-bo-docs.googleusercontent.com)... 173.194.222.132, 2a00:1450:4010:c0b::84
Connecting to doc-0c-bo-docs.googleusercontent.com (doc-0c-bo-docs.googleusercontent.com)|173.194.222.132|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: unspecified [application/x-gzip]
Saving to: ‘zfs_task1.tar.gz’

    [    <=>                                                                                                  ] 7,275,140   9.52MB/s   in 0.7s   

2020-11-19 17:01:34 (9.52 MB/s) - ‘zfs_task1.tar.gz’ saved [7275140]

FINISHED --2020-11-19 17:01:34--
Total wall clock time: 9.7s
Downloaded: 1 files, 6.9M in 0.7s (9.52 MB/s)
[root@zfs ~]# ls -lha
total 8.2M
dr-xr-x---.  4 root root  212 Nov 19 17:01 .
dr-xr-xr-x. 19 root root  270 Nov 19 16:49 ..
-rw-------.  1 root root 5.5K Apr 30  2020 anaconda-ks.cfg
-rw-r--r--.  1 root root   18 Dec 29  2013 .bash_logout
-rw-r--r--.  1 root root  176 Dec 29  2013 .bash_profile
-rw-r--r--.  1 root root  176 Dec 29  2013 .bashrc
-rw-r--r--.  1 root root  100 Dec 29  2013 .cshrc
drwx------.  2 root root   60 Nov 19 16:42 .gnupg
-rw-------.  1 root root 5.2K Apr 30  2020 original-ks.cfg
drwxr-xr-x.  2 root root   29 Nov 19 16:40 .ssh
-rw-r--r--.  1 root root  129 Dec 29  2013 .tcshrc
-rw-r--r--.  1 root root 1.2M May  6  2016 War_and_Peace.txt
-rw-r--r--.  1 root root 7.0M Nov 19 17:01 zfs_task1.tar.gz
```
</details> 
  
--------------------------------------------------------------------------------

Распаковываю полученный архив. 
<details><summary><code>[root@zfs ~]# gunzip ./zfs_task1.tar.gz</code></summary>
  
```shell
[root@zfs ~]# ls -lha
total 1002M
dr-xr-x---.  4 root root   209 Nov 19 17:02 .
dr-xr-xr-x. 19 root root   270 Nov 19 16:49 ..
-rw-------.  1 root root  5.5K Apr 30  2020 anaconda-ks.cfg
-rw-r--r--.  1 root root    18 Dec 29  2013 .bash_logout
-rw-r--r--.  1 root root   176 Dec 29  2013 .bash_profile
-rw-r--r--.  1 root root   176 Dec 29  2013 .bashrc
-rw-r--r--.  1 root root   100 Dec 29  2013 .cshrc
drwx------.  2 root root    60 Nov 19 16:42 .gnupg
-rw-------.  1 root root  5.2K Apr 30  2020 original-ks.cfg
drwxr-xr-x.  2 root root    29 Nov 19 16:40 .ssh
-rw-r--r--.  1 root root   129 Dec 29  2013 .tcshrc
-rw-r--r--.  1 root root  1.2M May  6  2016 War_and_Peace.txt
-rw-r--r--.  1 root root 1001M Nov 19 17:01 zfs_task1.tar
[root@zfs ~]# tar xvf ./zfs_task1.tar
zpoolexport/
zpoolexport/filea
zpoolexport/fileb
```
</details> 	
  
--------------------------------------------------------------------------------

Проверяю информацию о pool-e, импортирую его.
<details><summary><code>[root@zfs ~]# zpool import -d zpoolexport</code></summary>
  
```shell
   pool: otus
     id: 6554193320433390805
  state: ONLINE
 action: The pool can be imported using its name or numeric identifier.
 config:

	otus                         ONLINE
	  mirror-0                   ONLINE
	    /root/zpoolexport/filea  ONLINE
	    /root/zpoolexport/fileb  ONLINE
[root@zfs ~]# zpool import -d zpoolexport otus
```
</details> 
  
--------------------------------------------------------------------------------

Проверяю.
<details><summary><code>[root@zfs ~]# zpool list</code></summary>
  
```shell
NAME      SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus      480M  2.09M   478M        -         -     0%     0%  1.00x    ONLINE  -
zfsraid  3.75G  6.64M  3.74G        -         -     0%     0%  1.00x    ONLINE  -
[root@zfs ~]# zpool status
  pool: otus
 state: ONLINE
  scan: none requested
config:

	NAME                         STATE     READ WRITE CKSUM
	otus                         ONLINE       0     0     0
	  mirror-0                   ONLINE       0     0     0
	    /root/zpoolexport/filea  ONLINE       0     0     0
	    /root/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors

  pool: zfsraid
 state: ONLINE
  scan: none requested
config:

	NAME        STATE     READ WRITE CKSUM
	zfsraid     ONLINE       0     0     0
	  raidz1-0  ONLINE       0     0     0
	    sdb     ONLINE       0     0     0
	    sdc     ONLINE       0     0     0
	    sdd     ONLINE       0     0     0
	    sde     ONLINE       0     0     0

errors: No known data errors
```
</details> 
  
--------------------------------------------------------------------------------

Получаю сводную информацию о полученном разделе.
<details><summary><code>[root@zfs ~]# zfs get all otus</code></summary>
  
```shell
NAME  PROPERTY              VALUE                  SOURCE
otus  type                  filesystem             -
otus  creation              Fri May 15  4:00 2020  -
otus  used                  2.04M                  -
otus  available             350M                   -
otus  referenced            24K                    -
otus  compressratio         1.00x                  -
otus  mounted               yes                    -
otus  quota                 none                   default
otus  reservation           none                   default
otus  recordsize            128K                   local
otus  mountpoint            /otus                  default
otus  sharenfs              off                    default
otus  checksum              sha256                 local
otus  compression           zle                    local
otus  atime                 on                     default
otus  devices               on                     default
otus  exec                  on                     default
otus  setuid                on                     default
otus  readonly              off                    default
otus  zoned                 off                    default
otus  snapdir               hidden                 default
otus  aclinherit            restricted             default
otus  createtxg             1                      -
otus  canmount              on                     default
otus  xattr                 on                     default
otus  copies                1                      default
otus  version               5                      -
otus  utf8only              off                    -
otus  normalization         none                   -
otus  casesensitivity       sensitive              -
otus  vscan                 off                    default
otus  nbmand                off                    default
otus  sharesmb              off                    default
otus  refquota              none                   default
otus  refreservation        none                   default
otus  guid                  14592242904030363272   -
otus  primarycache          all                    default
otus  secondarycache        all                    default
otus  usedbysnapshots       0B                     -
otus  usedbydataset         24K                    -
otus  usedbychildren        2.01M                  -
otus  usedbyrefreservation  0B                     -
otus  logbias               latency                default
otus  objsetid              54                     -
otus  dedup                 off                    default
otus  mlslabel              none                   default
otus  sync                  standard               default
otus  dnodesize             legacy                 default
otus  refcompressratio      1.00x                  -
otus  written               24K                    -
otus  logicalused           1020K                  -
otus  logicalreferenced     12K                    -
otus  volmode               default                default
otus  filesystem_limit      none                   default
otus  snapshot_limit        none                   default
otus  filesystem_count      none                   default
otus  snapshot_count        none                   default
otus  snapdev               hidden                 default
otus  acltype               off                    default
otus  context               none                   default
otus  fscontext             none                   default
otus  defcontext            none                   default
otus  rootcontext           none                   default
otus  relatime              off                    default
otus  redundant_metadata    all                    default
otus  overlay               off                    default
otus  encryption            off                    default
otus  keylocation           none                   default
otus  keyformat             none                   default
otus  pbkdf2iters           0                      default
otus  special_small_blocks  0                      default
[root@zfs ~]# df -h
Filesystem      Size  Used Avail Use% Mounted on
devtmpfs        489M     0  489M   0% /dev
tmpfs           496M     0  496M   0% /dev/shm
tmpfs           496M  6.8M  489M   2% /run
tmpfs           496M     0  496M   0% /sys/fs/cgroup
/dev/sda1        40G  5.0G   35G  13% /
tmpfs           100M     0  100M   0% /run/user/1000
zfsraid         2.7G  128K  2.7G   1% /zfsraid
zfsraid/fs1     2.7G  1.3M  2.7G   1% /zfsraid/fs1
zfsraid/fs2     2.7G  1.3M  2.7G   1% /zfsraid/fs2
zfsraid/fs3     2.7G  1.3M  2.7G   1% /zfsraid/fs3
zfsraid/fs4     2.7G  1.3M  2.7G   1% /zfsraid/fs4
tmpfs           100M     0  100M   0% /run/user/0
otus            350M  128K  350M   1% /otus
otus/hometask2  352M  2.0M  350M   1% /otus/hometask2
```
</details> 	
  
--------------------------------------------------------------------------------

## 3. Найти сообщение от преподавателей.

Скачиваю снапшот.
<details><summary><code>[root@zfs ~]# wget --no-check-certificate -O otus_task2.file 'https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download'</code></summary>
  
```shell
--2020-11-19 17:53:57--  https://drive.google.com/u/0/uc?id=1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG&export=download
Resolving drive.google.com (drive.google.com)... 64.233.161.194, 2a00:1450:4010:c01::c2
Connecting to drive.google.com (drive.google.com)|64.233.161.194|:443... connected.
HTTP request sent, awaiting response... 302 Moved Temporarily
Location: https://doc-00-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/6tvppju1vh73e295b5bgtotdl2l74frd/1605808425000/16189157874053420687/*/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG?e=download [following]
Warning: wildcards not supported in HTTP.
--2020-11-19 17:53:58--  https://doc-00-bo-docs.googleusercontent.com/docs/securesc/ha0ro937gcuc7l7deffksulhg5h7mbp1/6tvppju1vh73e295b5bgtotdl2l74frd/1605808425000/16189157874053420687/*/1gH8gCL9y7Nd5Ti3IRmplZPF1XjzxeRAG?e=download
Resolving doc-00-bo-docs.googleusercontent.com (doc-00-bo-docs.googleusercontent.com)... 173.194.222.132, 2a00:1450:4010:c0b::84
Connecting to doc-00-bo-docs.googleusercontent.com (doc-00-bo-docs.googleusercontent.com)|173.194.222.132|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: unspecified [application/octet-stream]
Saving to: ‘otus_task2.file’

    [   <=>                                                                                                   ] 5,432,736   10.9MB/s   in 0.5s   

2020-11-19 17:53:59 (10.9 MB/s) - ‘otus_task2.file’ saved [5432736]

[root@zfs ~]# ls -lha
total 1007M
dr-xr-x---.  5 root root   272 Nov 19 17:31 .
dr-xr-xr-x. 20 root root   282 Nov 19 17:05 ..
-rw-------.  1 root root  5.5K Apr 30  2020 anaconda-ks.cfg
-rw-------.  1 root root  2.4K Nov 19 17:31 .bash_history
-rw-r--r--.  1 root root    18 Dec 29  2013 .bash_logout
-rw-r--r--.  1 root root   176 Dec 29  2013 .bash_profile
-rw-r--r--.  1 root root   176 Dec 29  2013 .bashrc
-rw-r--r--.  1 root root   100 Dec 29  2013 .cshrc
drwx------.  2 root root    60 Nov 19 16:42 .gnupg
-rw-------.  1 root root  5.2K Apr 30  2020 original-ks.cfg
-rw-r--r--.  1 root root  5.2M Nov 19 17:53 otus_task2.file
drwxr-xr-x.  2 root root    29 Nov 19 16:40 .ssh
-rw-r--r--.  1 root root   129 Dec 29  2013 .tcshrc
-rw-r--r--.  1 root root  1.2M May  6  2016 War_and_Peace.txt
-rw-r--r--.  1 root root 1001M Nov 19 17:01 zfs_task1.tar
drwxr-xr-x.  2 root root    32 May 15  2020 zpoolexport
```
</details> 	
    
--------------------------------------------------------------------------------

Подключаю снапшот.
<details><summary><code>[root@zfs ~]# zfs receive zfsraid/fs1@task2 < otus_task2.file</code></summary>
  
```shell
cannot receive new filesystem stream: destination 'zfsraid/fs1' exists
must specify -F to overwrite it
[root@zfs ~]# zfs receive zfsraid/task2 < otus_task2.file
```
</details> 	
    
--------------------------------------------------------------------------------

Проверяю.
<details><summary><code>[root@zfs ~]# zfs list</code></summary>
  
```shell
NAME             USED  AVAIL     REFER  MOUNTPOINT
otus            2.04M   350M       24K  /otus
otus/hometask2  1.88M   350M     1.88M  /otus/hometask2
zfsraid         8.72M  2.67G     38.2K  /zfsraid
zfsraid/fs1     1.20M  2.67G     1.20M  /zfsraid/fs1
zfsraid/fs2     1.19M  2.67G     1.19M  /zfsraid/fs2
zfsraid/fs3     1.19M  2.67G     1.19M  /zfsraid/fs3
zfsraid/fs4     1.19M  2.67G     1.19M  /zfsraid/fs4
zfsraid/task2   3.73M  2.67G     3.73M  /zfsraid/task2
```
</details> 	
    
--------------------------------------------------------------------------------

Просматриваю содержимое снапшота.
<details><summary><code>[root@zfs ~]# cd /zfsraid/task2/</code></summary>
  
```shell
[root@zfs task2]# ls -lha
total 3.4M
drwxr-xr-x. 3 root    root      11 May 15  2020 .
drwxr-xr-x. 7 root    root       7 Nov 19 17:54 ..
-rw-r--r--. 1 root    root       0 May 15  2020 10M.file
-rw-r--r--. 1 root    root    710K May 15  2020 cinderella.tar
-rw-r--r--. 1 root    root      65 May 15  2020 for_examaple.txt
-rw-r--r--. 1 root    root       0 May 15  2020 homework4.txt
-rw-r--r--. 1 root    root    303K May 15  2020 Limbo.txt
-rw-r--r--. 1 root    root    498K May 15  2020 Moby_Dick.txt
drwxr-xr-x. 3 vagrant vagrant    4 Dec 18  2017 task1
-rw-r--r--. 1 root    root    1.2M May  6  2016 War_and_Peace.txt
-rw-r--r--. 1 root    root    390K May 15  2020 world.sql
 ```
</details> 	
   
--------------------------------------------------------------------------------

Произвожу поиск обозначенного файла.
<details><summary><code>[root@zfs task2]# find . -name secret_message</code></summary>
  
```shell
./task1/file_mess/secret_message  
```
</details> 	
  
--------------------------------------------------------------------------------

Искомая фраза.
<details><summary><code>[root@zfs task2]# cat ./task1/file_mess/secret_message</code></summary>
  
```shell
https://github.com/sindresorhus/awesome
```
</details> 	
  
Profit!
