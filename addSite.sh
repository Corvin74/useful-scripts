#!/bin/bash

SITENAME=$1
ACTION=$2
DB=$3

if [[ -n $SITENAME && $ACTION == "add" ]]; then
	if ! [ -f /etc/apache2/sites-available/$SITENAME.conf ]; then
		echo "Настраиваем новый сайт $SITENAME"
		sudo echo "127.0.0.1	$SITENAME" >> /etc/hosts
		sudo echo "<VirtualHost *:80>
						ServerName $SITENAME
						ServerAdmin moiseev-kn@rt-socstroy.com
						DocumentRoot /home/corvin/server/$SITENAME
						ErrorLog /home/corvin/server/$SITENAME/log/error.log
						CustomLog /home/corvin/server/$SITENAME/log/access.log combined
						<Directory /home/corvin/server/$SITENAME/>
							AllowOverride All
							Require all granted
						</Directory>
					</VirtualHost>" >> /etc/apache2/sites-available/$SITENAME.conf
	fi
	if ! [[ -d /home/corvin/server/$SITENAME ]]; then
		sudo mkdir -p /home/corvin/server/$SITENAME/log
		sudo echo "<?php echo(__FILE__)?>" >> /home/corvin/server/$SITENAME/index.php
		sudo chown -R www-data:www-data /home/corvin/server/$SITENAME
		sudo chmod -R u+rw /home/corvin/server/$SITENAME
		sudo chmod -R g+rw /home/corvin/server/$SITENAME
		sudo a2ensite $SITENAME.conf
		sudo systemctl reload apache2
	else
		if ! [ -f /home/corvin/server/$SITENAME/index.php ]; then
			echo "<?php echo(__FILE__)?>" >> /home/corvin/server/$SITENAME/index.php
			sudo chown -R www-data:www-data /home/corvin/server/$SITENAME
			sudo chmod -R u+rw /home/corvin/server/$SITENAME
			sudo chmod -R g+rw /home/corvin/server/$SITENAME
			sudo a2ensite $SITENAME.conf
			sudo systemctl reload apache2
		fi
		echo "Папка /home/corvin/server/$SITENAME уже существует!"
	fi
	if [[ $DB == "Yes" ]]; then
		DBNAME=${SITENAME//./_}	# Заменяем в названии базы данных "." на "_"
		echo "Для создания базы данных ${DBNAME} введите пароль пользователя root MySQL:"
		read rootpasswd
		mysql -uroot -p${rootpasswd} -e "CREATE DATABASE IF NOT EXISTS ${DBNAME} DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;"
		mysql -uroot -p${rootpasswd} -e "CREATE USER ${DBNAME}@localhost IDENTIFIED BY 'eTx1234';"
		mysql -uroot -p${rootpasswd} -e "GRANT ALL PRIVILEGES ON ${DBNAME}.* TO '${DBNAME}'@'localhost';"
		mysql -uroot -p${rootpasswd} -e "FLUSH PRIVILEGES;"
	fi
fi
