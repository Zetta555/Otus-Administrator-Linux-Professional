## 1. [Создайте свой кастомный образ nginx на базе alpine.](#createimage)
## 2. [Определите разницу между контейнером и образом](#whatdiff)
## 3. [Ответьте на вопрос: Можно ли в контейнере собрать ядро?](#answer)
## 4. [Собранный образ необходимо запушить в docker hub и дать ссылку на ваш репозиторий.](#pushimage)

1. Образ nginx на базе alpine <a name="createimage"></a>  
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


2. Разница между контейнером и образом. <a name="whatdiff"></a>  
https://habr.com/ru/post/253877/  
Образ является шаблоном для контейнера.  
### Образы  
Docker-образ — это read-only шаблон. Например, образ может содержать операционку Ubuntu c Apache и приложением на ней. Образы используются для создания контейнеров. Docker позволяет легко создавать новые образы, обновлять существующие, или вы можете скачать образы созданные другими людьми. Образы — это компонента сборки docker-а.  
### Контейнеры  
Контейнеры похожи на директории. В контейнерах содержится все, что нужно для работы приложения. Каждый контейнер создается из образа. Контейнеры могут быть созданы, запущены, остановлены, перенесены или удалены. Каждый контейнер изолирован и является безопасной платформой для приложения. Контейнеры — это компонента работы.


3. Можно ли в контейнере собрать ядро? <a name="answer"></a>  
В принципе, возможно, установив компилятор, необходимые для него библиотеки, сделав доступными исходные тексты. Но запустить это ядро в контейнере не получится, т.к. контейнер использует ядро хостовой системы.

4. Сылка на собраный образ в docker hub <a name="pushimage"></a>
