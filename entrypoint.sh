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

SPARK_WORKLOAD="${DEPLOY_ENV}"

echo "SPARK_WORKLOAD: $SPARK_WORKLOAD"


if [ "$SPARK_WORKLOAD" == "master" ];
then    
    /usr/local/nifi-1.25.0/bin/nifi.sh start
    start-master.sh -h 0.0.0.0 -p 7077 --webui-port 8080 --properties-file spark-ha.conf
fi 

if [ "$SPARK_WORKLOAD" == "worker" ];
then
    start-worker.sh spark://hadoop-master:7077
fi 


