#!/bin/bash

cur_dir=$(dirname $(readlink -f "$0"))

orig_master_host=
new_master_host=

mha_password=mha4bass

mysql -umha -p$mha_password -h$new_master_host -e "set global super_read_only=0;set global read_only=0;"

$cur_dir/proxysql_failover.sh --command=start --ssh_user=mha --orig_master_host=$orig_master_host --orig_master_ip=$orig_master_host --orig_master_port=3306 --new_master_host=$new_master_host --new_master_ip=$new_master_host --new_master_port=3306 --new_master_user='mha'   --new_master_password=$mha_password
