#!/bin/bash

# This script(proxysql_online_switch.sh) will be called when execute `masterha_master_switch --master_state=alive`
#
# - Phase 1
#   Current master write freezing phase  
#   --command=stop or stopssh
# - Phase 2 
#   New master granting write phase  
#   --command=start
#
# In our use case, we only care about the third phase. The first and the second can be ignored
# And only the argument --command is useful. All the following arguments can be ignored.
# This script can not be shared among different projects. 
# You need to change the following variables according to the configuration in ProxySQL
# MHA manager calls this script like this:
# proxysql_online_switch.sh --command=stop --orig_master_host=192.168.212.50 --orig_master_ip=192.168.212.50 --orig_master_port=3306 --orig_master_user='mha' --new_master_host=192.168.212.51 --new_master_ip=192.168.212.51 --new_master_port=3306 --new_master_user='mha' --orig_master_ssh_user=root --new_master_ssh_user=root   --orig_master_password=xxx --new_master_password=xxx

# the master host group id configured in ProxySQL
# **It's very important to make sure that it is correct**
master_hg=0
# the current master IP configured in ProxySQL
# this ip will be overiden by the one fetched from ProxySQL
#master_ip=192.168.212.50
# the backup master IP
# this ip will be overiden by the parameter `new_master_ip` passed by mha manager
#backup_master_ip=192.168.212.51

# The proxysql hosts ,this is an array. 
# As it's possible to have more than one proxysql instance
# If you have more proxysqls,just add the ip to the array
# eg: proxysql_hosts=("127.0.0.1" "127.0.0.1")
proxysql_hosts=("11.0.1.59" "11.0.1.60")

#credentials to login proxysql's admin interface

admin_user=dba
admin_password=dba@che001.com


args=( "--command" "--ssh_user"  "--orig_master_host"  "--orig_master_ip"  "--orig_master_port"  "--new_master_host"  "--new_master_ip"  "--new_master_port" "--new_master_user" "new_master_password")

all=$*

arr=($all)


# check arguments but there's no need
#for a in ${arr[@]}
#do

#tmp=`echo $a | awk -F '=' '{print $1}'`
#if [[ ! "${args[@]}" =~ $tmp ]]; then
#  echo " Unkown parameters: $a"
#  usage
#  exit 1
#fi
#done

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

com=`argValue "command"`

# we are interested in this parameter
new_master_ip=`argValue "new_master_ip"`

backup_master_ip=$new_master_ip
# we can fetch the current master ip from proxysql
#master_ip=`mysql -u$admin_user -p$admin_password -h${proxysql_hosts[0]} -P6032 -NB -e "select hostname from runtime_mysql_servers where hostgroup_id=$master_hg" 2>/dev/null`
master_ip=`argValue "orig_master_ip"`

# Login to the old master
user=`argValue "orig_master_user"`
pass=`argValue "orig_master_password"`

if [ ! "$master_ip" ];then
  echo "master_ip is empty. Exit!"
  exit 1 # FIXME: How MHA manager will handle this exit code ?
fi

function proxysql_failover(){
  # this is necessary
  proxysql_host=$1

  # do the activation of the new master.
  # Since we're here, the original master must be definitely dead. 
  echo ""
  echo "*****Start failover"
  (
  echo "update mysql_servers set status='ONLINE',hostname='$backup_master_ip' where hostgroup_id=$master_hg and hostname='$master_ip';"
  echo "LOAD MYSQL SERVERS TO RUNTIME;"
  echo "SAVE MYSQL SERVERS TO DISK;"
  ) | mysql -u$admin_user -p$admin_password -h$proxysql_host -P6032 
  echo "*****Done!"
  echo ""

}

# Online switch over. to make the new master offline gracefully
function proxysql_offline_maser(){
  # this is necessary
   proxysql_host=$1 
   # The original master is forbiden to write. as MHA manager executes `FLUSH TABLES WITH READ LOCK` on it.
   # offline the original master
   echo ""
   echo "*****Off line the original master gracefully!"
   (
   echo "update mysql_servers set status='OFFLINE_SOFT' where hostgroup_id=$master_hg and hostname='$master_ip';"
   echo "LOAD MYSQL SERVERS TO RUNTIME;"
   )| mysql -u$admin_user -p$admin_password -h$proxysql_host -P6032
   echo "*****Done!"
   echo ""
   # Wait for the running transactions to finish
   # Fixme: sleep 1s could be a problem 
   sleep 1
}


#if [ x"$com" = x"status" ];then
#  echo "command is $com"
#  exit
#fi

if [ x"$com" = x"stop" ] || [ x"$com" = x"stopssh" ];then
  # Offline master on all the ProxySQLs
  for p in ${proxysql_hosts[@]}
  do
     proxysql_offline_maser $p
     #After the current master is offline, it's necessary to enable 'super_read_only' on it.
     # As MHA manager only turned 'read_only' on.
     echo "Enable super_read_only on the old master"
     mysql -u${user} -p${pass} -h${master_ip} -e "set global super_read_only = ON;"    
     echo "Done"
  done
  exit
fi

# we only handle 'start' command
if [ x"$com" = x"start" ];then
  echo "*start command*"
  echo "**do proxysql failover and activate the new master*"
  # failover all the ProxySQLs
  for p in ${proxysql_hosts[@]}
  do
      proxysql_failover $p
  done

fi
