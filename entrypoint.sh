#!/bin/bash

#start ssh
service ssh start

SPARK_WORKLOAD=$1

echo "SPARK_WORKLOAD: $SPARK_WORKLOAD"

if [ "$SPARK_WORKLOAD" == "master" ];
then
  #$HADOOP_HOME/sbin/start-dfs.sh
  #$HADOOP_HOME/sbin/start-yarn.sh
  #bash /usr/local/hbase/bin/start-hbase.sh

  start-master.sh -h hadoop-master -p 7077 --webui-port 8080 --properties-file spark-ha-master.conf
elif [ "$SPARK_WORKLOAD" == "worker" ];
then
  start-worker.sh spark://hadoop-master:7077,hadoop-secondary:7077
else
 # secondary master
 start-master.sh -h hadoop-secondary -p 7077 --webui-port 8080 --properties-file spark-ha-secondary.conf
fi