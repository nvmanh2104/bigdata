#!/bin/bash

# The default node number is 3
N=${1:-3}


# Start hadoop master container
sudo docker rm -f hadoop-master &> /dev/null

echo "start hadoop-master container..."
#sudo docker run -itd --net=hadoop  -p 50070:50070 -p 60010:60010  -p 8088:8088 	-p 9870:9870 -v /home/cdh/VienAI/data/hadoop/namenode:root/hdfs/namenode --name hadoop-master --hostname hadoop-master   ngovanmanh/hadoop:3.2.0
sudo docker run -itd \
                --net=hadoop \
                -p 50070:50070 \
				-p 60010:60010 \
                -p 8088:8088 \
				-p 9870:9870	\
				-v /opt/bigdata/namenode:/root/hdfs/namenode	\
                --name hadoop-master \
                --hostname hadoop-master \
                ngovanmanh/hadoop:3.2.0 &> /dev/null


# Start hadoop slave container
i=1
while [ $i -lt $N ]
do
	sudo docker rm -f hadoop-slave$i &> /dev/null
	echo "start hadoop-slave$i container..."
	sudo docker run -itd \
	                --net=hadoop \
					-v /opt/bigdata/datanode$i:/root/hdfs/datanode	\
	                --name hadoop-slave$i \
	                --hostname hadoop-slave$i \
	                ngovanmanh/hadoop:3.2.0 &> /dev/null
	i=$(( $i + 1 ))
done 

# Get into hadoop master container
sudo docker exec -it hadoop-master bash
