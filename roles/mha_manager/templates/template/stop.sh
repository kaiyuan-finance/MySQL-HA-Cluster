#!/bin/bash

cur_dir=$(dirname $(readlink -f "$0"))

#conf=$cur_dir/mha_test.cnf
conf=`find $cur_dir -name "*.cnf" | head -n 1`
masterha_stop --conf=$conf
