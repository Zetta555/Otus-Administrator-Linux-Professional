# otus-task002
## Работа с mdadm
- Добавить в Vagrantfile еще дисков
- Сломать/починить raid
- Собрать R0/R5/R10 на выбор
- Прописать собранный рейд в конф, чтобы рейд собирался при загрузке
- Создать GPT раздел и 5 партиций

### **В качестве проверки принимаются - измененный Vagrantfile, скрипт для создания рейда, конф для автосборки рейда при загрузке**

\* *доп. задание - Vagrantfile, который сразу собирает систему с подключенным рейдом*

\*\* *перенесети работающую систему с одним диском на RAID 1. Даунтайм на загрузку с нового диска предполагается. В качестве проверики принимается вывод команды lsblk до и после и описание хода решения (можно воспользовать утилитой Script).*

## Ход выполнения ДЗ.
1. <summary><code>[~/centos7]$ vagrant box add centos/7</code></summary><br/>

2. <summary><code>[~/centos7]$ vagrant init</code></summary><br/>  

3. копирую [Vagranfile](https://raw.githubusercontent.com/erlong15/otus-linux/master/Vagrantfile "Vagranfile") Алексея, добавляю секции дополнительных дисков.<br/>  
<details>
<summary>Вывод <code>[~/centos7]$ cat Vagrantfile  </code></summary>

```  
# -*- mode: ruby -*-
# vim: set ft=ruby :
MACHINES = {
  :otuslinux => {
        :box_name => "centos/7",
        :ip_addr => '192.168.11.101',
	:disks => {
		:sata1 => {
			:dfile => './sata1.vdi',
			:size => 250,
			:port => 1
		},
		:sata2 => {
			:dfile => './sata2.vdi',
			:size => 250, # Megabytes
			:port => 2
		},
		:sata3 => {
			:dfile => './sata3.vdi',
			:size => 250,
			:port => 3
		},
		:sata4 => {
			:dfile => './sata4.vdi',
			:size => 250, # Megabytes
			:port => 4
		},
		:sata5 => {
			:dfile => './sata5.vdi',
			:size => 250, # Megabytes
			:port => 5
		},
		:sata6 => {
			:dfile => './sata6.vdi',
			:size => 250, # Megabytes
			:port => 6
		}
	}
  },
}
Vagrant.configure("2") do |config|
  MACHINES.each do |boxname, boxconfig|
      config.vm.define boxname do |box|
          box.vm.box = boxconfig[:box_name]
          box.vm.host_name = boxname.to_s
          #box.vm.network "forwarded_port", guest: 3260, host: 3260+offset
          box.vm.network "private_network", ip: boxconfig[:ip_addr]
            box.vm.provider :virtualbox do |vb|
                    vb.customize ["modifyvm", :id, "--memory", "256"]
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
	      yum install -y mdadm smartmontools hdparm gdisk
  	  SHELL
      end
  end
end
```
</details><br/>    

4. <code>[~/centos7]$ vagrant up --provision </code><br/>  

5. <code>[~/centos7]$ vagrant ssh </code><br/>  

6. Смотрю существующие блочные устройства(диски) в созданной виртуальной машине<br/>
<details>
<summary>Вывод <code>[vagrant@otuslinux ~]$ lsblk  </code></summary>

```  
NAME   MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda      8:0    0   40G  0 disk 
`-sda1   8:1    0   40G  0 part /
sdb      8:16   0  250M  0 disk 
sdc      8:32   0  250M  0 disk 
sdd      8:48   0  250M  0 disk 
sde      8:64   0  250M  0 disk 
sdf      8:80   0  250M  0 disk 
sdg      8:96   0  250M  0 disk 
```
</details><br/>  
7. Проверяю подключенные диски на отсутствие метаданных raid. Если такие блоки найдены – необходимо отформатировать утилитой dd.<br/>
<details>
<summary>Вывод <code>[vagrant@otuslinux ~]$ sudo mdadm -E /dev/sd[b-g]   </code></summary>

```	
mdadm: No md superblock detected on /dev/sdb.
mdadm: No md superblock detected on /dev/sdc.
mdadm: No md superblock detected on /dev/sdd.
mdadm: No md superblock detected on /dev/sde.
mdadm: No md superblock detected on /dev/sdf.
mdadm: No md superblock detected on /dev/sdg.

```
</details> 
8. Обнуляю суперблоки:<br/>
<details>
<summary>Вывод <code>[vagrant@otuslinux ~]$ sudo mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g}  </code></summary>
  
```
mdadm: Unrecognised md component device - /dev/sdb
mdadm: Unrecognised md component device - /dev/sdc
mdadm: Unrecognised md component device - /dev/sdd
mdadm: Unrecognised md component device - /dev/sde
mdadm: Unrecognised md component device - /dev/sdf
mdadm: Unrecognised md component device - /dev/sdg
  
```
</details><br/>
9. Создаю RAID10 из 6 дисков<br/>
<details>
<summary>Вывод <code>[vagrant@otuslinux ~]$ sudo mdadm --create --verbose /dev/md0 -l 10 -n 6 /dev/sd{b,c,d,e,f,g}  </code></summary>
  
```	
mdadm: layout defaults to n2
mdadm: layout defaults to n2
mdadm: chunk size defaults to 512K
mdadm: size set to 253952K
mdadm: Defaulting to version 1.2 metadata
mdadm: array /dev/md0 started.
  
```
</details> <br/>
10. Проверяю создание RAID<br/>
<details>
<summary>Вывод <code>[vagrant@otuslinux ~]$ cat /proc/mdstat  </code></summary>
	  
```
Personalities : [raid10] 
md0 : active raid10 sdg[5] sdf[4] sde[3] sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 512K chunks 2 near-copies [6/6] [UUUUUU]
      
unused devices: <none>

[vagrant@otuslinux ~]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Sat Nov  7 12:22:52 2020
        Raid Level : raid10
        Array Size : 761856 (744.00 MiB 780.14 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 6
     Total Devices : 6
       Persistence : Superblock is persistent

       Update Time : Sat Nov  7 12:22:56 2020
             State : clean 
    Active Devices : 6
   Working Devices : 6
    Failed Devices : 0
     Spare Devices : 0

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : bfe06357:a47dfd22:9121ae8e:38d1a67e
            Events : 17

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync set-A   /dev/sdb
       1       8       32        1      active sync set-B   /dev/sdc
       2       8       48        2      active sync set-A   /dev/sdd
       3       8       64        3      active sync set-B   /dev/sde
       4       8       80        4      active sync set-A   /dev/sdf
       5       8       96        5      active sync set-B   /dev/sdg
         
```
</details> <br/>
11. Создаю mdadm.conf<br/>
<details>
<summary>Вывод <code>[vagrant@otuslinux ~]$ sudo mdadm --detail --scan --verbose  </code></summary>
	  
```
ARRAY /dev/md0 level=raid10 num-devices=6 metadata=1.2 name=otuslinux:0 UUID=bfe06357:a47dfd22:9121ae8e:38d1a67e
   devices=/dev/sdb,/dev/sdc,/dev/sdd,/dev/sde,/dev/sdf,/dev/sdg
[vagrant@otuslinux ~]$ cd /etc/
[vagrant@otuslinux etc]$ sudo mkdir mdadm
[vagrant@otuslinux etc]$ sudo -i
[root@otuslinux ~]# echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
[root@otuslinux ~]# mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf
[root@otuslinux ~]# cat /etc/mdadm/mdadm.conf
DEVICE partitions
ARRAY /dev/md0 level=raid10 num-devices=6 metadata=1.2 name=otuslinux:0 UUID=bfe06357:a47dfd22:9121ae8e:38d1a67e
[root@otuslinux ~]# logout
  
```
</details> <br/>
12. "Ломаю" RAID<br/>
<details>
<summary>Вывод <code>[vagrant@otuslinux etc]$ sudo mdadm /dev/md0 --fail /dev/sde  </code></summary>
	  
```
mdadm: set /dev/sde faulty in /dev/md0
[vagrant@otuslinux etc]$ cat /proc/mdstat
Personalities : [raid10] 
md0 : active raid10 sdg[5] sdf[4] sde[3](F) sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 512K chunks 2 near-copies [6/5] [UUU_UU]
      
unused devices: <none>
[vagrant@otuslinux etc]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Sat Nov  7 12:22:52 2020
        Raid Level : raid10
        Array Size : 761856 (744.00 MiB 780.14 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 6
     Total Devices : 6
       Persistence : Superblock is persistent

       Update Time : Sat Nov  7 12:30:58 2020
             State : clean, degraded 
    Active Devices : 5
   Working Devices : 5
    Failed Devices : 1
     Spare Devices : 0

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : bfe06357:a47dfd22:9121ae8e:38d1a67e
            Events : 19

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync set-A   /dev/sdb
       1       8       32        1      active sync set-B   /dev/sdc
       2       8       48        2      active sync set-A   /dev/sdd
       -       0        0        3      removed
       4       8       80        4      active sync set-A   /dev/sdf
       5       8       96        5      active sync set-B   /dev/sdg

       3       8       64        -      faulty   /dev/sde
         
```
</details><br/> 	   
13. Чиню RAID<br/>
<details>
<summary>Вывод <code>[vagrant@otuslinux etc]$ sudo mdadm /dev/md0 --remove /dev/sde </code></summary>
	  
```
mdadm: hot removed /dev/sde from /dev/md0

[vagrant@otuslinux etc]$ sudo mdadm /dev/md0 --add /dev/sde
mdadm: added /dev/sde
[vagrant@otuslinux etc]$ cat /proc/mdstat
Personalities : [raid10] 
md0 : active raid10 sde[6] sdg[5] sdf[4] sdd[2] sdc[1] sdb[0]
      761856 blocks super 1.2 512K chunks 2 near-copies [6/6] [UUUUUU]
      
unused devices: <none>
[vagrant@otuslinux etc]$ sudo mdadm -D /dev/md0
/dev/md0:
           Version : 1.2
     Creation Time : Sat Nov  7 12:22:52 2020
        Raid Level : raid10
        Array Size : 761856 (744.00 MiB 780.14 MB)
     Used Dev Size : 253952 (248.00 MiB 260.05 MB)
      Raid Devices : 6
     Total Devices : 6
       Persistence : Superblock is persistent

       Update Time : Sat Nov  7 12:33:03 2020
             State : clean 
    Active Devices : 6
   Working Devices : 6
    Failed Devices : 0
     Spare Devices : 0

            Layout : near=2
        Chunk Size : 512K

Consistency Policy : resync

              Name : otuslinux:0  (local to host otuslinux)
              UUID : bfe06357:a47dfd22:9121ae8e:38d1a67e
            Events : 39

    Number   Major   Minor   RaidDevice State
       0       8       16        0      active sync set-A   /dev/sdb
       1       8       32        1      active sync set-B   /dev/sdc
       2       8       48        2      active sync set-A   /dev/sdd
       6       8       64        3      active sync set-B   /dev/sde
       4       8       80        4      active sync set-A   /dev/sdf
       5       8       96        5      active sync set-B   /dev/sdg
         
```
</details> <br/>
14. Создаю GPT раздел, пять партиций и монтирую их на RAID-диск.<br/>  

Создаю раздел GPT на RAID.<br/>
<summary><code>[vagrant@otuslinux etc]$ sudo parted -s /dev/md0 mklabel gpt </code></summary><br/>
Создаю 5 разделов.<br/>
<details>
<summary>Вывод <code>[vagrant@otuslinux etc]$ sudo parted /dev/md0 mkpart primary ext4 0% 20% </code></summary>
	  
```
Information: You may need to update /etc/fstab.
[vagrant@otuslinux etc]$ sudo parted /dev/md0 mkpart primary ext4 20% 40% 
Information: You may need to update /etc/fstab.
[vagrant@otuslinux etc]$ sudo parted /dev/md0 mkpart primary ext4 40% 80% 
Information: You may need to update /etc/fstab.
[vagrant@otuslinux etc]$ sudo parted /dev/md0 mkpart primary ext4 80% 90% 
Information: You may need to update /etc/fstab.
[vagrant@otuslinux etc]$ sudo parted /dev/md0 mkpart primary ext4 90% 100%
Information: You may need to update /etc/fstab.
```
</details> <br/>
Создаю ФС на разделах<br/>
<details>
<summary>Вывод <code>[vagrant@otuslinux etc]$ for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md0p$i; done </code></summary>
	  
```
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
37696 inodes, 150528 blocks
7526 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
1984 inodes per group
Superblock backups stored on blocks: 
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done 

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
38152 inodes, 152064 blocks
7603 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33816576
19 block groups
8192 blocks per group, 8192 fragments per group
2008 inodes per group
Superblock backups stored on blocks: 
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done 

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
76608 inodes, 305664 blocks
15283 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33947648
38 block groups
8192 blocks per group, 8192 fragments per group
2016 inodes per group
Superblock backups stored on blocks: 
	8193, 24577, 40961, 57345, 73729, 204801, 221185

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (8192 blocks): done
Writing superblocks and filesystem accounting information: done 

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
18880 inodes, 75264 blocks
3763 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33685504
10 block groups
8192 blocks per group, 8192 fragments per group
1888 inodes per group
Superblock backups stored on blocks: 
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done 

mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=1024 (log=0)
Fragment size=1024 (log=0)
Stride=512 blocks, Stripe width=1536 blocks
18880 inodes, 75264 blocks
3763 blocks (5.00%) reserved for the super user
First data block=1
Maximum filesystem blocks=33685504
10 block groups
8192 blocks per group, 8192 fragments per group
1888 inodes per group
Superblock backups stored on blocks: 
	8193, 24577, 40961, 57345, 73729

Allocating group tables: done                            
Writing inode tables: done                            
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done 
  
```
</details> <br/>
Создаю директории, в которые будут монтироваться созданные разделы<br/>
<details>
<summary>Вывод <code>[vagrant@otuslinux etc]$ cd / </code></summary>
	  
```
[vagrant@otuslinux /]$ sudo mkdir -p /raid/part{1,2,3,4,5}
[vagrant@otuslinux /]$ cd /raid/
[vagrant@otuslinux raid]$ ll
total 0
drwxr-xr-x. 2 root root 6 Nov  7 12:36 part1
drwxr-xr-x. 2 root root 6 Nov  7 12:36 part2
drwxr-xr-x. 2 root root 6 Nov  7 12:36 part3
drwxr-xr-x. 2 root root 6 Nov  7 12:36 part4
drwxr-xr-x. 2 root root 6 Nov  7 12:36 part5
```
</details><br/>  
Монтирую созданные разделы<br/>  
<summary><code>[vagrant@otuslinux raid]$ for i in $(seq 1 5); do sudo mount /dev/md0p$i /raid/part$i; done </code></summary><br/>
15. Смотрю вывод lsblk<br/>
<details>
<summary>Вывод <code>[vagrant@otuslinux raid]$ lsblk </code></summary>
	  
```
NAME      MAJ:MIN RM   SIZE RO TYPE   MOUNTPOINT
sda         8:0    0    40G  0 disk   
`-sda1      8:1    0    40G  0 part   /
sdb         8:16   0   250M  0 disk   
`-md0       9:0    0   744M  0 raid10 
  |-md0p1 259:0    0   147M  0 md     /raid/part1
  |-md0p2 259:1    0 148.5M  0 md     /raid/part2
  |-md0p3 259:2    0 298.5M  0 md     /raid/part3
  |-md0p4 259:3    0  73.5M  0 md     /raid/part4
  `-md0p5 259:4    0  73.5M  0 md     /raid/part5
sdc         8:32   0   250M  0 disk   
`-md0       9:0    0   744M  0 raid10 
  |-md0p1 259:0    0   147M  0 md     /raid/part1
  |-md0p2 259:1    0 148.5M  0 md     /raid/part2
  |-md0p3 259:2    0 298.5M  0 md     /raid/part3
  |-md0p4 259:3    0  73.5M  0 md     /raid/part4
  `-md0p5 259:4    0  73.5M  0 md     /raid/part5
sdd         8:48   0   250M  0 disk   
`-md0       9:0    0   744M  0 raid10 
  |-md0p1 259:0    0   147M  0 md     /raid/part1
  |-md0p2 259:1    0 148.5M  0 md     /raid/part2
  |-md0p3 259:2    0 298.5M  0 md     /raid/part3
  |-md0p4 259:3    0  73.5M  0 md     /raid/part4
  `-md0p5 259:4    0  73.5M  0 md     /raid/part5
sde         8:64   0   250M  0 disk   
`-md0       9:0    0   744M  0 raid10 
  |-md0p1 259:0    0   147M  0 md     /raid/part1
  |-md0p2 259:1    0 148.5M  0 md     /raid/part2
  |-md0p3 259:2    0 298.5M  0 md     /raid/part3
  |-md0p4 259:3    0  73.5M  0 md     /raid/part4
  `-md0p5 259:4    0  73.5M  0 md     /raid/part5
sdf         8:80   0   250M  0 disk   
`-md0       9:0    0   744M  0 raid10 
  |-md0p1 259:0    0   147M  0 md     /raid/part1
  |-md0p2 259:1    0 148.5M  0 md     /raid/part2
  |-md0p3 259:2    0 298.5M  0 md     /raid/part3
  |-md0p4 259:3    0  73.5M  0 md     /raid/part4
  `-md0p5 259:4    0  73.5M  0 md     /raid/part5
sdg         8:96   0   250M  0 disk   
`-md0       9:0    0   744M  0 raid10 
  |-md0p1 259:0    0   147M  0 md     /raid/part1
  |-md0p2 259:1    0 148.5M  0 md     /raid/part2
  |-md0p3 259:2    0 298.5M  0 md     /raid/part3
  |-md0p4 259:3    0  73.5M  0 md     /raid/part4
  `-md0p5 259:4    0  73.5M  0 md     /raid/part5
```
</details><br/>

16. Скрипт создания RAID10 на 6-ти дисках<br/>
<details>
<summary>Вывод <code>[root@otuslinux]# cat addraid.sh </code></summary>

```
#!/bin/bash

mdadm --zero-superblock --force /dev/sd{b,c,d,e,f,g}
mdadm --create --verbose /dev/md0 -l 10 -n 6 /dev/sd{b,c,d,e,f,g}
parted -s /dev/md0 mklabel gpt
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 80%
parted /dev/md0 mkpart primary ext4 80% 90%
parted /dev/md0 mkpart primary ext4 90% 100%
for i in $(seq 1 5); do mkfs.ext4 /dev/md0p$i; done
mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do  mount /dev/md0p$i /raid/part$i; done

[root@otuslinux ~]#     

```
</details><br/>
