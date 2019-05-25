#!/bin/bash
cur_dir=$(dirname $(readlink -f "$0"))

#conf=$cur_dir/mha_test.cnf
conf=`find $cur_dir -name "*.cnf" | head -n 1`

# master_state:dead , alive
# --new_master_host (optional if you want to indicate the new master)
#masterha_master_switch --master_state=alive --conf=$conf
masterha_master_switch --master_state=alive --conf=$conf --orig_master_is_new_slave --interactive=0

#masterha_master_switch --master_state=dead --conf=$conf --dead_master_host=11.0.1. --interactive=0

# After switch , the original master is dropped. You can add it as a replica to the new master
# change master to master_host='192.168.212.51',master_user='repl',master_password='repl',master_auto_position=1;
