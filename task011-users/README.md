# otus-task011
## Пользователи и группы. Авторизация и аутентификация
1. Запретить всем пользователям, кроме группы admin логин в выходные (суббота и воскресенье), без учета праздников  
* дать конкретному пользователю права работать с докером  
и возможность рестартить докер сервис  

# Выполнение задания
Проверяю вход простым пользователем в будний день
<details><summary><code>$> ssh friday@127.0.0.1 -p 2222</code></summary>

```shell

friday@127.0.0.1's password: 
Last login: Tue Feb  9 00:00:18 2021 from 10.0.2.2
[friday@pam ~]$ logout
Connection to 127.0.0.1 closed.
  
```
</details> 

Вхожу пользователем, добавленным в группу sudo, запускаю docker контейнер, перезапускаю службу docker 
<details><summary><code>$> ssh day@127.0.0.1 -p 2222</code></summary>

```shell

day@127.0.0.1's password: 
Last login: Sun Feb  7 00:00:56 2021 from 10.0.2.2
[day@pam ~]$ sudo docker run hello-world
[sudo] password for day: 

Hello from Docker!
This message shows that your installation appears to be working correctly.

[day@pam ~]$ sudo systemctl restart docker 
[day@pam ~]$ sudo systemctl status docker
● docker.service - Docker Application Container Engine
   Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2021-02-09 00:48:04 UTC; 8s ago
     Docs: https://docs.docker.com
 Main PID: 26012 (dockerd)
    Tasks: 9
   Memory: 90.4M
   CGroup: /system.slice/docker.service
           └─26012 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock

Feb 09 00:48:03 pam dockerd[26012]: time="2021-02-09T00:48:03.590520526Z" level=info msg="ccResolverWrapper: sending update to cc: {[{u...ule=grpc
Feb 09 00:48:03 pam dockerd[26012]: time="2021-02-09T00:48:03.590529878Z" level=info msg="ClientConn switching balancer to \"pick_first...ule=grpc
Feb 09 00:48:03 pam dockerd[26012]: time="2021-02-09T00:48:03.601774628Z" level=info msg="[graphdriver] using prior storage driver: overlay2"
Feb 09 00:48:03 pam dockerd[26012]: time="2021-02-09T00:48:03.611848952Z" level=info msg="Loading containers: start."
Feb 09 00:48:03 pam dockerd[26012]: time="2021-02-09T00:48:03.810320183Z" level=info msg="Default bridge (docker0) is assigned with an ...address"
Feb 09 00:48:03 pam dockerd[26012]: time="2021-02-09T00:48:03.854516380Z" level=info msg="Loading containers: done."
Feb 09 00:48:04 pam dockerd[26012]: time="2021-02-09T00:48:04.016947691Z" level=info msg="Docker daemon" commit=46229ca graphdriver(s)=...=20.10.3
Feb 09 00:48:04 pam dockerd[26012]: time="2021-02-09T00:48:04.017036596Z" level=info msg="Daemon has completed initialization"
Feb 09 00:48:04 pam systemd[1]: Started Docker Application Container Engine.
Feb 09 00:48:04 pam dockerd[26012]: time="2021-02-09T00:48:04.082484417Z" level=info msg="API listen on /var/run/docker.sock"
Hint: Some lines were ellipsized, use -l to show in full.
[day@pam ~]$ sudo systemctl restart docker
[day@pam ~]$ sudo systemctl status docker
● docker.service - Docker Application Container Engine
   Loaded: loaded (/usr/lib/systemd/system/docker.service; enabled; vendor preset: disabled)
   Active: active (running) since Tue 2021-02-09 00:48:17 UTC; 9s ago
     Docs: https://docs.docker.com
 Main PID: 26152 (dockerd)
    Tasks: 9
   Memory: 79.1M
   CGroup: /system.slice/docker.service
              └─26152 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
  
```
</details> 

Меняю дату на дату выходного дня
<details><summary><code>$> ssh day@127.0.0.1 -p 2222</code></summary>

```shell

[day@pam ~]$ sudo date +%Y%m%d -s "20210207"
[sudo] password for day: 
Sorry, try again.
[sudo] password for day: 
20210207
[day@pam ~]$ date
Sun Feb  7 00:00:02 UTC 2021
[day@pam ~]$ date +%u
7
[day@pam ~]$ logout
Connection to 127.0.0.1 closed.
  
```
</details> 

Пытаюсь подключиться пользователем, не входящего в группу admin, пользователю доступ запрещён. Задание выполнено
<details><summary><code>$> ssh friday@127.0.0.1 -p 2222</code></summary>

```shell

friday@127.0.0.1's password: 
Permission denied, please try again.
  
```
</details> 
