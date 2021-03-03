## 1. [Создайте свой кастомный образ nginx на базе alpine.](#createimage)
## 2. [Определите разницу между контейнером и образом](#whatdiff)
## 3. [Ответьте на вопрос: Можно ли в контейнере собрать ядро?](#answer)
## 4. [Собранный образ необходимо запушить в docker hub и дать ссылку на ваш репозиторий.](#pushimage)

### 1. Образ nginx на базе alpine <a name="createimage"></a>  
Сформировал [Dockerfile](docker/Dockerfile)   
Запускаю demon Docker  
<code>$> systemctl start docker</code>  
Проверяю работу Docker
<details><summary><code>$> systemctl status docker </code></summary>
      
```shell
● docker.service - Docker Application Container Engine
   Loaded: loaded (/usr/lib/systemd/system/docker.service; disabled; vendor preset: disabled)
   Active: active (running) since Ср 2021-03-03 14:27:20 MSK; 8min ago
     Docs: https://docs.docker.com
 Main PID: 10095 (dockerd)
    Tasks: 16
   Memory: 162.2M
   CGroup: /system.slice/docker.service
           └─10095 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
```
</details> 
<details><summary><code>$> docker run hello-world</code></summary>
      
```shell

Hello from Docker!
This message shows that your installation appears to be working correctly.
```
</details> 
<details><summary><code>$> docker images</code></summary>
      
```shell
REPOSITORY    TAG       IMAGE ID       CREATED         SIZE
hello-world   latest    bf756fb1ae65   14 months ago   13.3kB
```
</details> 

<details><summary><code>$> docker build -t zetta55/alpng:v1.0 .</code></summary>
      
```shell
Sending build context to Docker daemon   5.12kB
Step 1/8 : FROM alpine:3.13
 ---> 28f6e2705743
Step 2/8 : RUN apk update && apk add nginx && rm -rf /var/cache/apk/*
 ---> Running in 027d77e02e54
fetch https://dl-cdn.alpinelinux.org/alpine/v3.13/main/x86_64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.13/community/x86_64/APKINDEX.tar.gz
v3.13.2-58-ge3f19cedc6 [https://dl-cdn.alpinelinux.org/alpine/v3.13/main]
v3.13.2-57-gb49ace1568 [https://dl-cdn.alpinelinux.org/alpine/v3.13/community]
OK: 13877 distinct packages available
(1/2) Installing pcre (8.44-r0)
(2/2) Installing nginx (1.18.0-r13)
Executing nginx-1.18.0-r13.pre-install
Executing nginx-1.18.0-r13.post-install
Executing busybox-1.32.1-r3.trigger
OK: 7 MiB in 16 packages
Removing intermediate container 027d77e02e54
 ---> c3b12435a1ca
Step 3/8 : RUN adduser -D -g 'www' www && mkdir /www && chown -R www:www /var/lib/nginx && chown -R www:www /www
 ---> Running in 76f8135645f5
Removing intermediate container 76f8135645f5
 ---> d4c904e0f88d
Step 4/8 : RUN mkdir -p /run/nginx
 ---> Running in be72637aa5f9
Removing intermediate container be72637aa5f9
 ---> 2439d94bc9c7
Step 5/8 : COPY index.html /www
 ---> 4a4988ad0c6f
Step 6/8 : COPY nginx.conf /etc/nginx/nginx.conf
 ---> f7c4f182eaa6
Step 7/8 : EXPOSE 80
 ---> Running in 1f0ee6b6a3c3
Removing intermediate container 1f0ee6b6a3c3
 ---> ec6b8e29f356
Step 8/8 : CMD ["nginx", "-g", "daemon off;"]
 ---> Running in 52a04964c05f
Removing intermediate container 52a04964c05f
 ---> f9ac11d6cb47
Successfully built f9ac11d6cb47
Successfully tagged zetta55/alpng:v1.0
```
</details> 
<details><summary><code>$> docker images</code></summary>
      
```shell
REPOSITORY      TAG       IMAGE ID       CREATED          SIZE
zetta55/alpng   v1.0      f9ac11d6cb47   13 seconds ago   7.04MB
alpine          3.13      28f6e2705743   13 days ago      5.61MB
hello-world     latest    bf756fb1ae65   14 months ago    13.3kB
```
</details> 

<code>$> docker run -p 80:80 -t zetta55/alpng:v1.0</code>

<details><summary><code>$> docker ps | grep zetta</code></summary>
      
```shell
d0ef7b36480e   zetta55/alpng:v1.0   "nginx -g 'daemon of…"   4 seconds ago   Up 3 seconds   0.0.0.0:80->80/tcp   jovial_hypatia
```
</details> 
<details><summary><code>$> curl localhost</code></summary>
      
```shell
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <title>HTML5</title>
</head>
<body>
    Server is online
</body>
</html>
```
</details> 

### 2. Разница между контейнером и образом. <a name="whatdiff"></a>  
https://habr.com/ru/post/253877/  
Образ является шаблоном для контейнера.  
#### Образы  
Docker-образ — это read-only шаблон. Например, образ может содержать операционку Ubuntu c Apache и приложением на ней. Образы используются для создания контейнеров. Docker позволяет легко создавать новые образы, обновлять существующие, или вы можете скачать образы созданные другими людьми. Образы — это компонента сборки docker-а.  
#### Контейнеры  
Контейнеры похожи на директории. В контейнерах содержится все, что нужно для работы приложения. Каждый контейнер создается из образа. Контейнеры могут быть созданы, запущены, остановлены, перенесены или удалены. Каждый контейнер изолирован и является безопасной платформой для приложения. Контейнеры — это компонента работы.


### 3. Можно ли в контейнере собрать ядро? <a name="answer"></a>  
В принципе, возможно, установив компилятор, необходимые для него библиотеки, сделав доступными исходные тексты. Но запустить это ядро в контейнере не получится, т.к. контейнер использует ядро хостовой системы.

### 4. Сылка на собраный образ в docker hub <a name="pushimage"></a>
<details><summary><code>$> docker login </code></summary>
      
```shell
Login with your Docker ID to push and pull images from Docker Hub. If you don't have a Docker ID, head over to https://hub.docker.com to create one.
Username: zetta55
Password: 
WARNING! Your password will be stored unencrypted in /home/discentem/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

Login Succeeded
```
</details> 
<details><summary><code>$> docker push zetta55/alpng:v1.0</code></summary>
      
```shell
The push refers to repository [docker.io/zetta55/alpng]
88885cbd49ba: Pushed 
78f5ead21337: Pushed 
26728a4a01b5: Pushed 
dcee2c006940: Pushed 
cba4d50c4c21: Pushed 
cb381a32b229: Mounted from library/alpine 
v1.0: digest: sha256:1d99eb80a4171f1cba3d8826c0240215dca5a63f5ce91b558e382150dcaea9f5 size: 1567
```
</details> 
<details><summary><code>$> docker pull zetta55/alpng:v1.0</code></summary>
      
```shell
v1.0: Pulling from zetta55/alpng
ba3557a56b15: Pull complete 
0789809e908a: Pull complete 
5e74dc7d7677: Pull complete 
584f40acd761: Pull complete 
63110641bc6e: Pull complete 
5a4cd0f41c98: Pull complete 
Digest: sha256:1d99eb80a4171f1cba3d8826c0240215dca5a63f5ce91b558e382150dcaea9f5
Status: Downloaded newer image for zetta55/alpng:v1.0
docker.io/zetta55/alpng:v1.0
```
</details> 
