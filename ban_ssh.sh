#!/bin/sh

# Данный скрипт просматривает файлы журналов
# на предмет подозрительной активности и при
# обнаружении оной добавляет правила в фаервол
# pf
#
#
#

# Создание и инициализация необходимых переменных

# Текущий день
DAY=`date +%d`
# Текущий месяц
MONTH=`date +%m`
# Текущий год
YEAR=`date +%Y`
# Указываем путь к папке где будут храниться логи
LOG_DIR="/var/old_log/${YEAR}/${MONTH}"
#LOG_DIR="/home/corvin/scripts/tests/old_log/${YEAR}/${MONTH}"
# Создаём папку для логов если она не существует
mkdir -p ${LOG_DIR}
# Задаем имя файла логов за текущий день (для логов из файла
# /var/log/auth.log)
LOG_FILE_AUTH="${LOG_DIR}/${DAY}_auth.log"


# Переносим логи в бекап и очищаем оригинальный файл
cat /var/log/auth.log > /tmp/auth.log
cat /dev/null > /var/log/auth.log
# Для локальных тестов
#cat /home/$USER/scripts/old_log/2014/05/07_auth.log > /home/$USER/scripts/tests/log/auth.log
#cat /home/$USER/scripts/tests/log/auth.log > /tmp/auth.log
#cat /dev/null > /home/$USER/scripts/tests/log/auth.log

cat /tmp/auth.log >> ${LOG_FILE_AUTH}

# Вначале отлавливаем IP с которых пытаются залогинится
# под несуществующими пользователями
echo "Несуществующий пользователь(Invalid user)"
cat ${LOG_FILE_AUTH} | grep "Invalid user" | awk '{print $10}' | sort | uniq -c  | sort |
{
	while read count_IP
	do
		count_deny=`echo ${count_IP} | awk '{print $1}'`
		IP=`echo ${count_IP} | awk '{print $2}'`
		if [ ${count_deny} -ge 3 ]
		then
			echo "IP address  = ${IP}      deny count =    ${count_deny}"
			echo "/sbin/pfctl -t bad_boy -T add ${IP}"
			/sbin/pfctl -t bad_boy -T add ${IP}
			/sbin/pfctl -t bad_boy -T show | awk '{print $1}' > /etc/pf/bad_boy.tbl
		fi
	done
}

# Теперь отловим IP с которых пытаются залогинится
# под существующими пользователями но не перечисленными в AllowUsers
echo "Существующий пользователь но не перечислен в AllowUsers"
cat ${LOG_FILE_AUTH} | grep "not allowed because not listed in AllowUsers" | awk '{print $9}' | sort | uniq -c  | sort |
{
	while read count_IP
	do
		count_deny=`echo ${count_IP} | awk '{print $1}'`
		IP=`echo ${count_IP} | awk '{print $2}'`
		if [ ${count_deny} -ge 3 ]
		then
			echo "IP address  = ${IP}      deny count =    ${count_deny}"
			echo "/sbin/pfctl -t bad_boy -T add ${IP}"
			/sbin/pfctl -t bad_boy -T add ${IP}
			/sbin/pfctl -t bad_boy -T show | awk '{print $1}' > /etc/pf/bad_boy.tbl
		fi
	done
}

################ messages.log ################

LOG_FILE_MESSAGES="${LOG_DIR}/${DAY}_messages.log"
# Переносим логи в бекап и очищаем оригинальный файл
cat /var/log/messages > /tmp/messages.log
cat /dev/null > /var/log/messages
cat /tmp/messages.log >> ${LOG_FILE_MESSAGES}

# Вначале отлавливаем IP с которых пытаются залогинится
# под несуществующими пользователями
echo "Несуществующий пользователь(Illegal user)"
cat ${LOG_FILE_MESSAGES} | grep "illegal user" | awk '{print $15}' | sort | uniq -c  | sort |
{
	while read count_IP
	do
		count_deny=`echo ${count_IP} | awk '{print $1}'`
		IP=`echo ${count_IP} | awk '{print $2}'`
		if [ ${count_deny} -ge 3 ]
		then
			echo "IP address  = ${IP}      deny count =    ${count_deny}"
			echo "/sbin/pfctl -t bad_boy -T add ${IP}"
			/sbin/pfctl -t bad_boy -T add ${IP}
			/sbin/pfctl -t bad_boy -T show | awk '{print $1}' > /etc/pf/bad_boy.tbl
		fi
	done
}

# Присекаем попытки редиректа
echo "Попытка ICMP редиректа(icmp redirect)"
cat ${LOG_FILE_MESSAGES} | grep "icmp redirect" | awk '{print $9}' | sort | uniq -c  | sort |
{
	while read count_IP
	do
		count_deny=`echo ${count_IP} | awk '{print $1}'`
		IP=`echo ${count_IP} | awk '{print $2}'`
		if [ ${count_deny} -ge 2 ]
		then
			echo "IP address  = ${IP}      deny count =    ${count_deny}"
			echo "/sbin/pfctl -t bad_boy -T add ${IP}"
			/sbin/pfctl -t bad_boy -T add ${IP}
			/sbin/pfctl -t bad_boy -T show | awk '{print $1}' > /etc/pf/bad_boy.tbl
		fi
	done
}