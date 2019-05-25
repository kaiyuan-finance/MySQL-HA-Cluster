#!/bin/bash

cur_dir=$(dirname $(readlink -f "$0"))

statusf=".master_status.health"
n=`ls $cur_dir | grep $statusf | wc -l`

if [ $n -ne 0 ];then
  echo "masterha_manager is already running... Exit!"
  exit
fi


#conf=$cur_dir/mha_test.cnf
#log=$cur_dir/test.log

conf=`find $cur_dir -name "*.cnf" | head -n 1`
log=`find $cur_dir -name "*.log" | head -n 1`
nohup masterha_manager --conf=$conf < /dev/null > $log 2>&1 &

