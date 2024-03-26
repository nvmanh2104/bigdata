#!/bin/bash

# The default node number is 3
N=6


# Start hadoop slave container
i=3
while [ $i -lt $N ]
do
	sudo docker rm -f hadoop-slave$i &> /dev/null
	echo "start hadoop-slave$i container..."
	sudo docker run -itd \
	                --net=aws_system_network \
					-v /opt/bigdata/datanode$i:/root/hdfs/datanode	\
	                --name hadoop-slave$i \
	                --hostname hadoop-slave$i \
	                ngovanmanh/hadoop:3.2.0 &> /dev/null
	i=$(( $i + 1 ))
done 

# Get into hadoop master container
sudo docker exec -it hadoop-master bash
