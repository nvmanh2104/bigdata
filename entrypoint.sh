#!/bin/bash

#start ssh
service ssh start

SPARK_WORKLOAD=$1

echo "SPARK_WORKLOAD: $SPARK_WORKLOAD"

if [ "$SPARK_WORKLOAD" == "master" ];
then
  # start zookeeper  
  echo $ZOOKEEPER_ID > $ZOOKEEPER_DATA/myid
  systemctl start zk.service
  systemctl enable zk.service
  $ZOOKEEPER_HOME/bin/zkCli.sh -server 127.0.0.1:2181
  # start spark
  start-master.sh -p 7077 --webui-port 8080 --properties-file spark-ha.conf
elif [ "$SPARK_WORKLOAD" == "worker" ];
then
  start-worker.sh spark://hadoop-master:7077,hadoop-secondary:7077
else
 # secondary master
 #start-master.sh -h hadoop-secondary -p 7077 --webui-port 8080 --properties-file spark-ha.conf
fi