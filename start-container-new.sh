#!/bin/bash

# The default node number is 3
N=${1:-3}


# Start hadoop master container
sudo docker rm -f hadoop-master &> /dev/null

echo "start hadoop-master container..."
#sudo docker run -itd --net=hadoop  -p 50070:50070 -p 60010:60010  -p 8088:8088 	-p 9870:9870 -v /home/cdh/VienAI/data/hadoop/namenode:root/hdfs/namenode --name hadoop-master --hostname hadoop-master   ngovanmanh/hadoop:3.2.0
sudo docker run -itd \
                --net=detai \
				-p 9000:9000 \
                -p 50070:50070 \
				-p 60010:60010 \
                -p 8088:8088 \
				-p 9870:9870	\
				-p 8080:8080	\
				-p 7077:7077 \
				-v /home/cdh/VienAI/data/hadoop/namenode:/root/hdfs/namenode	\
                --name hadoop-master \
                --hostname hadoop-master \
				-e SPARK_TYPE='master' \
                ngovanmanh/hadoop-detai:3.2.0 #&> /dev/null


# Start hadoop slave container
i=1
while [ $i -lt $N ]
do
	sudo docker rm -f hadoop-slave$i &> /dev/null
	echo "start hadoop-slave$i container..."
	sudo docker run -itd \
	                --net=detai \
					-v /home/cdh/VienAI/data/hadoop/datanode$i:/root/hdfs/datanode	\
					-e SPARK_TYPE='worker' \
	                --name hadoop-slave$i \
	                --hostname hadoop-slave$i  ngovanmanh/hadoop-detai:3.2.0 #&> /dev/null
	i=$(( $i + 1 ))
done 

# Get into hadoop master container
sudo docker exec -it hadoop-master bash
