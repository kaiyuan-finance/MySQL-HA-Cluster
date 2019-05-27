#!/bin/bash

# Try to stop all the mysqld processes with -9 , including mysqld and mysqld_safe.
# As it is possible that mysqld process is in progress of restart by mysqld_safe when mha manager detect that master is not reachable.
# /dbfiles/mha_manager/scripts/shutdown_mysql.sh --command=stopssh --ssh_user=root  --host=192.168.212.51  --ip=192.168.212.51  --port=3306  
# The script will be called twice:
# 1. when start monitoring
#   --command=status
#   --host=(maser's hostname)
#   --ip=(master's ip address)
# 2. during failvoer
#   --command=stopssh
#   --ssh_user=(ssh username so that you can connect to the master)
#   --host=(master's hostname)
#   --ip=(master's ip address)
#   --port=(master's port number)
#   --pid_file=(master's pid file)

#parse the arguments and get the corresponding value 

all=$*

arr=($all)
function argValue(){
  para=$1
  for a in ${arr[@]}
  do
    c=`echo "$a" | grep "$para" | wc -l`
    if [ $c -eq 1 ];then
       echo $a | awk -F '=' '{print $2}'
       break;
    fi    
  done
}

com=`argValue "command"`
masterIP=`argValue "ip"`
sshUser=`argValue "ssh_user"`
echo "command is :$com"

if [ x"$com" = x"stopssh" ];  then
  # kills all mysqld and mysqld_safe processes
  ssh -o ConnectTimeout=1 ${sshUser}@${masterIP} "if [ `pgrep mysqld` ];then pgrep mysqld | xargs sudo kill -9 ; fi"
  echo " ***** Killed mysqld mysqld_safe *****"
  echo "" 
  exit 10
fi

# If we reach here, ssh is not reachable
# We can do nothing to power off the VM 
if [ x"$com" = x"stop" ];then
:
fi
