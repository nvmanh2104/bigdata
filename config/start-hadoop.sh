#!/bin/bash

echo -e "\n"

/usr/local/hadoop/bin/hdfs namenode -format

echo -e "\n"

$HADOOP_HOME/sbin/start-dfs.sh

echo -e "\n"

$HADOOP_HOME/sbin/start-yarn.sh

echo -e "\n"

