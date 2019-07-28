#!/bin/bash
echo 'Введите имя базы:'
read DBNAME_TMP

DBNAME=${DBNAME_TMP//./_}
echo $DBNAME
