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

hbase thrift start -p 6660