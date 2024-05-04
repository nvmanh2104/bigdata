#!/bin/bash

echo -e "\n"
# zookeeper to HA
#hdfs zkfc -formatZK

echo -e "\n"

$HADOOP_HOME/sbin/start-dfs.sh

echo -e "\n"

$HADOOP_HOME/sbin/start-yarn.sh

echo -e "\n"
bash /usr/local/hbase/bin/start-hbase.sh

# chay tren ca 3 master node
hbase thrift start -p 6660

# hive
- hadoop-master1: hive --service metastore --hiveconf hive.root.logger=INFO,console
- hadoop-master3: hive --service hiveserver2 --hiveconf hive.root.logger=INFO,console
- !connect jdbc:hive2://hadoop-master3:10000/default
- user/pass: APP/mine