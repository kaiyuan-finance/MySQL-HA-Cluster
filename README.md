# MySQL HA Cluster

## 部署架构


## 部署步骤
### 1. 编辑文件hosts.ini  
hosts.ini文件包含了所有的主机信息，是标准ansible inventory文件  

[mysql_servers:vars]中定义了  
mysql的数据目录（datadir）  
日志目录(logdir)  
临时文件目录(tmpdir)  
已经所安装的mysql版本(mysql_version,目前支持mysql5.7的各版本安装，若安装mysql8,则需要编辑mysql角色下的相关task)



[proxysql_servers:vars] 下面定义了  
proxysql的安装目录（proxysql_datadir）  
proxysql的日志目录（proxysql_logdir）   
proxysql客户端端口（proxysql_client_port）  
proxysql中的sql_mode（mysql_sql_mode）  
proxysql监控账号及密码（proxysql_monitor_user、proxysql_monitor_password）  
proxysql的版本（proxysql_version）  

[mha_manager_servers:vars] 变量组定义了  
MHA manager的目录（mhadir），该目录中会有所有的项目，每个项目以一个文件夹的形式配置  
MHA监控mysql server的账号及密码（mysql_mha_user、mysql_mha_password）  
SSH账号（ssh_user）, **注意：各MHA node节点的SSH 公钥互信需要手工配置**  

### 2. 部署
2.1 部署整个集群
部署整个集群可以运行一下代码，若想只部署某个部分，见2.2以后
```
ansible-playbook -i hosts.ini start_deploy.yml
```
2.2 只部署ProxySQL
```
ansible-playbook -i hosts.ini -t install-proxysql start_deploy.yml
```
2.3 只部署MySQL
```
ansible-playbook -i hosts.ini -t install-mysql start_deploy.yml
```
2.4 部署MHA node
所有MySQL节点，以及MHA Manager都需要部署，此步骤应在安装MHA manager之前执行
```
ansible-playbook -i hosts.ini -t install-mha-node start_deploy.yml
```
2.5 部署MHA Manager
```
ansible-playbook -i hosts.ini -t install-mha-manager start_deploy.yml
```
