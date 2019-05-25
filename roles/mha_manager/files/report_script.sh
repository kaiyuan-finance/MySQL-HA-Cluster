#!/bin/bash

# Call noah inerface to send messages to dbas

all=$*
arr=($all)

#parse the arguments and get the corresponding value
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

subject=`argValue "subject"`
orig_master=`argValue "orig_master_host"`
new_master=`argValue "new_master_host"`
new_slave_hosts=`argValue "new_slave_hosts"`
body=`argValue "body"`
body="Project-$subject MHA Master Failover!\r\n 新Master:$new_master\r\n 故障Master:$orig_master"

# send message alert to people relative
