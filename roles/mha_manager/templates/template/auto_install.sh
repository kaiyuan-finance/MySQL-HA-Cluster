#!/bin/bash

if [ $# -ne 1 ];then
echo "Please input the project name."
exit
fi

project=$1

#cur_dir=$(dirname $(readlink -f "$0"))

echo "Correct the cnf/log file name..."
mv mha_project.cnf mha_${project}.cnf
mv mha_project.log mha_${project}.log
echo "done"
echo ""

echo "Correct the parent folder"
#mv ../template ../mha_$project
echo "done"

echo "Correct  the content of cnf "

sed -i "s#PROJECT#$project#g" mha_${project}.cnf

echo "done"

echo "You still need to change the server host part in  mha_${project}.cnf"

cd ..
cd mha_$project
ls -l
