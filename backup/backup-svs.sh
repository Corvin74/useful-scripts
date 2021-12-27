#!/bin/bash
# Имя сервера, который архивируем
SRV_NAME=srv1
# Адрес сервера, который архивируем
SRV_IP=127.0.0.1
# Пользователь rsync на сервере, который архивируем
SRV_USER=backup
ALL_LOG=/backup/log/temp.log

# Подключаем сеть удаленного офиса
echo "Start connecting VPN"
`systemctl start openvpn@client_svs`
if [ $? -eq 0 ]
then
  echo "Successfully connected to VPN"
  `sleep 5`
  echo "Start mounting network share"
  #`mount.cifs //192.168.10.11/all /mnt/svs -o user=support,domain=office.local,pass=eTx1243`
  `mount.cifs //192.168.10.11/all /mnt/svs -o credentials=/root/.smbclient`
  if [ $? -eq 0 ]
  then
    echo "Successfully mounting network share. Start backup..."
    `touch /mnt/svs/test.txt && echo "$(date +%Y-%m-%d\ %H:%M:%S) Ok" >> /mnt/svs/test.txt`
    `umount /mnt/svs`
  else
    echo "Could not mount device!!!" >&2
  fi
  `systemctl stop openvpn@client_svs`
else
  echo "Could not connecting to network!!!" >&2
fi

echo "" > ${ALL_LOG}

# Подключаем сеть удаленного офиса
`systemctl start openvpn@client_svs`
`mount.cifs //192.168.10.11/all /mnt/svs -o user=support,domain=office.local,pass=eTx1243`
`touch /mnt/svs/test.txt && echo "$(date +%Y-%m-%d\ %H:%M:%S) Ok" >> /mnt/svs/test.txt`
# Ресурс на сервере для бэкапа
SRV_DIR=all
# Папка, куда будем складывать архивы
BACKUP_DIR=/backup/${SRV_NAME}/${SRV_DIR}/
SUBJS="Start backup ${SRV_DIR} on ${SRV_NAME} at "$(date  +%Y-%m-%d\ %H:%M:%S)
echo -e ${SUBJS}
echo -e ${SUBJS} >> ${ALL_LOG}
#echo -e ${SUBJS} | mail -s "$(echo -e "${SUBJS}\nContent-Type: text/plain; charset=UTF-8\nContent-Transfer-Encoding: quoted-printable")" oit@rt-socstroy.com
# Создаем папку для инкрементных бэкапов
mkdir -p ${BACKUP_DIR}increment/
# Запускаем непосредственно бэкап с параметрами
OUT=$( /usr/bin/rsync -a --delete --info=progress2 --password-file=/etc/rsyncd.pwd ${SRV_USER}@${SRV_IP}::${SRV_DIR} ${BACKUP_DIR}current/ --backup --backup-dir=${BACKUP_DIR}increment/`date +%Y-%m-%d`/`date +%H:%M:%S`/ 2>&1 >/dev/null)
echo -e ${OUT}
echo -e ${OUT} >> ${ALL_LOG}
# Чистим папки с инкрементными архивами старше 30-ти дней
/usr/bin/find ${BACKUP_DIR}increment/ -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \;
#date
SUBJF="Finish backup ${SRV_DIR} on ${SRV_NAME} at "$(date  +%Y-%m-%d\ %H:%M:%S)
echo -e ${SUBJF}
echo -e ${SUBJF} >> ${ALL_LOG}
#echo -e ${OUT} | mail -s "$(echo -e "${SUBJF}\nContent-Type: text/plain; charset=UTF-8\nContent-Transfer-Encoding: quoted-printable")" oit@rt-socstroy.com
OUT=""

# Ресурс на сервере для бэкапа
SRV_DIR=departments
# Папка, куда будем складывать архивы
BACKUP_DIR=/backup/${SRV_NAME}/${SRV_DIR}/
SUBJS="Start backup ${SRV_DIR} on ${SRV_NAME} at "$(date  +%Y-%m-%d\ %H:%M:%S)
echo -e ${SUBJS}
echo -e ${SUBJS} >> ${ALL_LOG}
#echo -e ${SUBJS} | mail -s "$(echo -e "${SUBJS}\nContent-Type: text/plain; charset=UTF-8\nContent-Transfer-Encoding: quoted-printable")" oit@rt-socstroy.com
# Создаем папку для инкрементных бэкапов
mkdir -p ${BACKUP_DIR}increment/
# Запускаем непосредственно бэкап с параметрами
OUT=$( /usr/bin/rsync -a --delete --info=progress2 --password-file=/etc/rsyncd.pwd ${SRV_USER}@${SRV_IP}::${SRV_DIR} ${BACKUP_DIR}current/ --backup --backup-dir=${BACKUP_DIR}increment/`date +%Y-%m-%d`/`date +%H:%M:%S`/ 2>&1 >/dev/null)
echo -e ${OUT}
echo -e ${OUT} >> ${ALL_LOG}
# Чистим папки с инкрементными архивами старше 30-ти дней
/usr/bin/find ${BACKUP_DIR}increment/ -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \;
#date
SUBJF="Finish backup ${SRV_DIR} on ${SRV_NAME} at "$(date  +%Y-%m-%d\ %H:%M:%S)
echo -e ${SUBJF}
echo -e ${SUBJF} >> ${ALL_LOG}
#echo -e ${OUT} | mail -s "$(echo -e "${SUBJF}\nContent-Type: text/plain; charset=UTF-8\nContent-Transfer-Encoding: quoted-printable")" oit@rt-socstroy.com
OUT=""

# Ресурс на сервере для бэкапа
SRV_DIR=old_share
# Папка, куда будем складывать архивы
SYST_DIR=/backup/${SRV_NAME}/${SRV_DIR}/
SUBJS="Start backup ${SRV_DIR} on ${SRV_NAME} at "$(date  +%Y-%m-%d\ %H:%M:%S)
echo -e ${SUBJS}
echo -e ${SUBJS} >> ${ALL_LOG}
#echo -e ${SUBJS} | mail -s "$(echo -e "${SUBJS}\nContent-Type: text/plain; charset=UTF-8\nContent-Transfer-Encoding: quoted-printable")" oit@rt-socstroy.com
# Создаем папку для инкрементных бэкапов
mkdir -p ${SYST_DIR}increment/
# Запускаем непосредственно бэкап с параметрами
OUT=$( /usr/bin/rsync -a --delete --info=progress2 --password-file=/etc/rsyncd.pwd ${SRV_USER}@${SRV_IP}::${SRV_DIR} ${SYST_DIR}current/ --backup --backup-dir=${SYST_DIR}increment/`date +%Y-%m-%d`/`date +%H:%M:%S`/ 2>&1 >/dev/null)
echo -e ${OUT}
echo -e ${OUT} >> ${ALL_LOG}
# Чистим папки с инкрементными архивами старше 30-ти дней
/usr/bin/find ${SYST_DIR}increment/ -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \;
SUBJF="Finish backup ${SRV_DIR} on ${SRV_NAME} at "$(date  +%Y-%m-%d\ %H:%M:%S)
echo -e ${SUBJF}
echo -e ${SUBJF} >> ${ALL_LOG}
#echo -e ${OUT} | mail -s "$(echo -e "${SUBJF}\nContent-Type: text/plain; charset=UTF-8\nContent-Transfer-Encoding: quoted-printable")" oit@rt-socstroy.com
OUT=""

