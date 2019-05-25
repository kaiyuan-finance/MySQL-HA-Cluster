#!/bin/bash

if [ $UID -ne 0 ];then
echo "You're not root! Exit."
exit
fi 

yum localinstall perl-DBD-MySQL-4.013-3.el6.x86_64.rpm -y

yum install "perl(Module::Install)" -y

yum install gcc -y

echo "+++++++++Install mha node..."
tar xzf v0.58_mha_node.tar.gz

cd mha4mysql-node-0.58

perl Makefile.PL
make
make install

echo "+++++++++Done"
echo ""

cd ..

echo "+++++++++install ExtUtils-Constant"

tar xzf ExtUtils-Constant-0.25.tar.gz

cd ExtUtils-Constant-0.25 
perl Makefile.PL
make
make install

echo "++++++++Done"
echo ""

cd ..
echo "+++++++++install Socket"
tar xzf Socket-2.027.tar.gz
cd Socket-2.027
perl Makefile.PL
make
make install

echo "++++++++Done"
echo ""

echo "++++++ Add to path"
c=`echo $PATH | grep /usr/local/bin | wc -l`
if [ $c -eq 0 ];then
 echo "PATH=$PATH:/usr/local/bin" >> /etc/profile; source /etc/profile;
fi
cd ..
#cp purge_relay_log_cron.sh /usr/local/bin/
#add crontab: purge_relay_log_cron.sh 
#TODO:
echo "Finished!"
