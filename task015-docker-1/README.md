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

$> docker build -t zetta55/alpng:v1.0 .
Sending build context to Docker daemon   5.12kB
Step 1/7 : FROM alpine:3.13
3.13: Pulling from library/alpine
ba3557a56b15: Already exists 
Digest: sha256:a75afd8b57e7f34e4dad8d65e2c7ba2e1975c795ce1ee22fa34f8cf46f96a3be
Status: Downloaded newer image for alpine:3.13
 ---> 28f6e2705743
Step 2/7 : RUN apk update && apk add nginx && rm -rf /var/cache/apk/*
 ---> Running in 03117f8d27cb
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
Removing intermediate container 03117f8d27cb
 ---> 2d266877ab8a
Step 3/7 : RUN adduser -D -g 'www' www && mkdir /www && chown -R www:www /var/lib/nginx && chown -R www:www /www
 ---> Running in b1b118c426bf
Removing intermediate container b1b118c426bf
 ---> 70c7141b1f76
Step 4/7 : COPY index.html /www
 ---> 369bccf2c2b9
Step 5/7 : COPY nginx.conf /etc/nginx/nginx.conf
 ---> 8afac38ebfa9
Step 6/7 : EXPOSE 80
 ---> Running in c2a87e7f8a59
Removing intermediate container c2a87e7f8a59
 ---> 6479b1f91544
Step 7/7 : CMD ["nginx", "-g", "daemon off;"]
 ---> Running in 1c68b595fc62
Removing intermediate container 1c68b595fc62
 ---> 191427ee7224
Successfully built 191427ee7224
Successfully tagged zetta55/alpng:v1.0

$> docker images
REPOSITORY      TAG       IMAGE ID       CREATED              SIZE
zetta55/alpng   v1.0      191427ee7224   About a minute ago   7.04MB
alpine          3.13      28f6e2705743   13 days ago          5.61MB
hello-world     latest    bf756fb1ae65   14 months ago        13.3kB


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
