#!/bin/bash
CUR_DIR=`pwd`
mkdir $CUR_DIR/tmp
#echo $CUR_DIR
rm -rf $CUR_DIR/tmp/*
jpegoptim -d $CUR_DIR/tmp -f -m 80 -p *.jpg
