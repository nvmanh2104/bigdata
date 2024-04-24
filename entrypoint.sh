#!/bin/bash

#start ssh
service ssh start

#test
# echo "Start shell............."
# while [ 1 ]
# do    
#     sleep 20
# done
#end test

SPARK_WORKLOAD=$1

echo "SPARK_WORKLOAD: $SPARK_WORKLOAD"


if [ "$SPARK_WORKLOAD" == "master1" ];
then
    /etc/init.d/nifi start
    start-master.sh -h 0.0.0.0 -p 7077 --webui-port 8080 --properties-file spark-ha.conf
fi 

if [ "$SPARK_WORKLOAD" == "master2" ];
then
    /etc/init.d/nifi start
    start-master.sh -h 0.0.0.0 -p 7077 --webui-port 8080 --properties-file spark-ha.conf
fi 

if [ "$SPARK_WORKLOAD" == "master3" ];
then
    /etc/init.d/nifi start
    start-master.sh -h 0.0.0.0 -p 7077 --webui-port 8080 --properties-file spark-ha.conf
fi 

if [ "$SPARK_WORKLOAD" == "worker" ];
then
    start-worker.sh spark://hadoop-master1:7077,hadoop-master2:7077,hadoop-master3:7077
fi 


# if [ "$SPARK_WORKLOAD" == "master" ];
# then
#   # start zookeeper  
#   # echo $ZOOKEEPER_ID > $ZOOKEEPER_DATA/myid
#   # cd /opt/zookeeper
#   # java -cp zookeeper-3.4.9.jar:lib/log4j-1.2.16.jar:lib/slf4j-log4j12-1.6.1.jar:lib/slf4j-api-1.6.1.jar:conf org.apache.zookeeper.server.quorum.QuorumPeerMain conf/zoo.cfg

#   # $ZOOKEEPER_HOME/bin/zkCli.sh -server localhost:2181
#   # start spark
#   start-master.sh -p 7077 --webui-port 8080 --properties-file spark-ha.conf
# elif [ "$SPARK_WORKLOAD" == "worker" ];
# then
#   start-worker.sh spark://hadoop-master1:2181,hadoop-master2:2181,hadoop-master3:2181
# else
#  # secondary master
#    echo "else"
#  #start-master.sh -h hadoop-secondary -p 7077 --webui-port 8080 --properties-file spark-ha.conf
# fi
