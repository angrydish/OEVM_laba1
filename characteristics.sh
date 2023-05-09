#!/bin/bash
if [[ `dpkg -s speedtest | grep Status` == "" ]] && [[ $"$1" == "-s" ]]; then
	ustanovlen="false"
	clear
	echo Пакет speedtest для проверки скорости соединения не установлен. Установить? "[y|n]"
	read soglasen
	if [[ $soglasen == "y" ]]; then
		sudo apt-get install curl
		curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
		sudo apt-get install speedtest
		ustanovlen="true"
	else
		soglasen="n"
		break
	fi

else
	ustanovlen="true"
	soglasen="y"
fi
clear
echo Дата: `date`
echo Имя учетной записи: `whoami`
echo Доменное имя ПК: `hostname`
echo Процессор:
echo -e "\t" `lscpu | grep -E 'Model name|модели'`
echo -e "\t" `lscpu | grep -E 'Архитектура|Architecture'`
echo -e "\t" `lscpu | grep -E "CPU max MHz|CPU MHz" `
echo -e "\t Ядер на сокет:" `lscpu | grep -E "Ядер на сокет|per socket" | awk '{print $4}'`
echo -e "\t Потоков на ядро:" `lscpu | grep -E "Потоков на ядро|per core" | awk '{print $4}'`
echo Оперативная память:
echo -e "\t Всего:" `free -h | grep -E 'Память|Mem' | awk '{print $2}'`
echo -e "\t Доступно:" `free -h | grep -E 'Память|Mem' | awk '{print $7}'`
echo Жесткий диск:
echo -e "\t Всего:" `df -h | grep /dev/sdc4 | awk '{print $2}'`
echo -e "\t Доступно:" `df -h | grep /dev/sdc4 | awk '{print $4}'`
echo -e "\t Смонтировано в корневую директорию:" `df -h | grep /dev/sdc4 | awk '{print $6}'`;
echo -e "\t SWAP всего:" `free -h | grep -E 'Подкачка|Swap' | awk '{print $2}'`
echo -e "\t SWAP доступно:" `free -h | grep -E 'Подкачка|Swap' | awk '{print $4}'`
echo Сетевые интерфейсы:
echo -e "\t Количество сетевых интерфейсов:" `ls /sys/class/net | wc -l`
count=1
tabs 20
echo -e "\t №\tИмя\t\t MAC\t\t\t IP"
for t in `ls /sys/class/net`; do
	mac=`ip a show $t | grep ether | awk '{print $2}'`
	ip=`ip a show $t | grep -w inet | awk '{print $2}'`
	if [[ $"$mac" == "" ]]; then
		echo -e "\t $count\t$t\t\t" "no mac provided\t\t\t" $ip
	else
		echo -e "\t $count\t$t\t\t" $mac "\t\t\t" $ip
	fi
	let "count+=1"
done
tabs 4
if [[ $"$1" == "-s" ]]; then
	if [[ $ustanovlen == "true" ]] && [[ $soglasen == "y" ]];then
		echo Скорость:
		speedtest --accept-license -p no | grep -E "(Download|Upload)" | awk '{print $3 $4}'>./res.txt &
		#speedtest -p no | grep -E "(Download|Upload)">./res.txt &
		spin[0]="-"
		spin[1]="\\"
		spin[2]="|"
		spin[3]="/"
		#pid=`ps aux | grep -i "speedtest -p no" | head -1 | awk '{print $2}'`
		pid=`pgrep speedtest`
		while kill -0 $pid 2>/dev/null;
		do
		  for i in "${spin[@]}"
		  do
		        echo -ne "\b$i"
		        sleep 0.1
		  done
		done
		echo -ne "\b"
		#cat res.txt
		#cat res.txt | awk '{print $3 $4}'
		echo "Загрузка: " `cat res.txt | head -1`
		echo "Отдача: " `cat res.txt | tail -1`
	fi
else
	exit
fi
