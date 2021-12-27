#!/bin/bash

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

