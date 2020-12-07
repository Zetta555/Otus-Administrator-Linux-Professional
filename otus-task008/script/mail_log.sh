#!/bin/bash

#скрипт для крона
#который раз в час присылает на заданную почту
#- X IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
#- Y запрашиваемых адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта
#- все ошибки c момента последнего запуска
#- список всех кодов возврата с указанием их кол-ва с момента последнего запуска

# Защита от мультизапуска скрипта
exec 200<$0
flock -n 200 
if [ $? -gt 0 ];
	then
		echo "Script already running"
		exit 1
	else
		echo "Script running"
fi

# Сохраняю в переменную BASEDIR путь к каталогу, где находится скрипт
BASEDIR=$(dirname $(realpath "$0"))

# Вывожу в консоль значение BASEDIR
echo $BASEDIR

# Объявляю переменные, используемые скриптом.
wwwlog=$BASEDIR/access.log
message=$BASEDIR/message
runtime=$BASEDIR/runtime
temp=$BASEDIR/temp.log
emailaddr=${USER}@localhost
ipcount=10
urlcount=10

prepare(){
    if ! [[  -f $runtime ]];then
        head -1 $wwwlog | awk '{print $4}' | sed 's/\[//' > $runtime;
    fi
    processingtime=$(cat $runtime | sed 's!/!\\/!g')
    starttime=$(cat $runtime)
    sed -n "/${processingtime}/,$ p" $wwwlog > $temp
    tail -1 $temp | awk '{print $4}' | sed 's/\[//' > $runtime
    endtime=$(cat $runtime)
}

parser() {
    echo "================================================" > $message
    echo "Проверка лога с  $starttime по $endtime" >> $message
    echo "================================================" >> $message

    #IP-адресов с наибольшим кол-вом запросов
    echo "------------------------------------------------" >> $message
    echo "$ipcount IP-адресов с наибольшим кол-вом запросов:" >> $message
    awk '{print $1}' $temp | sort | uniq -cd | sort -nr | head -$ipcount | awk '{printf "%5s %s\n", $1, " requests from IP: " $2}' >> $message
    echo "------------------------------------------------" >> $message

    #URL's с наибольшим количеством запросов
    echo "------------------------------------------------" >> $message
    echo "$urlcount URL' с наибольшим количеством запросов:" >> $message
    awk '{print $7}' $temp | sort | uniq -cd | sort -nr | head -$urlcount | awk '{printf "%5s %s\n", $1, " requests for: " $2}' >> $message
    echo "------------------------------------------------" >> $message

    #Список ошибок на стороне клиента
    echo "------------------------------------------------" >> $message
    echo "Список ошибок на стороне клиента:" >> $message
    awk '($9 ~ /4../){print $9}' $temp | sort | uniq -cd | sort -nr |  awk '{printf "%5s %s\n", $1, " errors with code: " $2}' >> $message 
    echo "------------------------------------------------" >> $message

    #Список ошибок на стороне сервера
    echo "------------------------------------------------" >> $message
    echo "Список ошибок на стороне сервера:" >> $message
    awk '($9 ~ /5../){print $9}' $temp | sort | uniq -cd | sort -nr |  awk '{printf "%5s %s\n", $1, " errors with code: " $2}' >> $message 
    echo "------------------------------------------------" >> $message
    
    #Список всех кодов возврата
    echo "------------------------------------------------" >> $message
    echo "Список всех кодов возврата:" >> $message
    awk '{print $9}' $temp | sort | uniq -cd | sort -nr |  awk '{printf "%5s %s\n", $1, " responses with HTTP status code: " $2}' >> $message
    echo "------------------------------------------------" >> $message
}

prepare
parser

sleep 10

date=$(date)
cp $message "$message+$date"
mail -s "Analise access log" "$emailaddr" < $message

trap "rm -f "$temp";exit $?" INT TERM EXIT
rm -f $temp
trap - INT TERM EXIT


