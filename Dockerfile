# FROM ubuntu:14.04
FROM ubuntu:18.04

MAINTAINER manh.ngovan <manh.ngovan@gmail.com>

WORKDIR /root

RUN apt-get update && apt-get install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN apt install python3.7 -y

RUN add-apt-repository ppa:openjdk-r/ppa

# install openssh-server, openjdk and wget
RUN apt-get install -y openssh-server openjdk-8-jdk wget

# install hadoop 2.7.2
# RUN wget https://github.com/kiwenlau/compile-hadoop/releases/download/2.7.2/hadoop-2.7.2.tar.gz  && \
#     tar -xzvf hadoop-2.7.2.tar.gz && \
#     mv hadoop-2.7.2 /usr/local/hadoop && \
#     rm hadoop-2.7.2.tar.gz

RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-3.2.0/hadoop-3.2.0.tar.gz && \
    tar -xzvf hadoop-3.2.0.tar.gz && \
    mv hadoop-3.2.0 /usr/local/hadoop && \
    rm hadoop-3.2.0.tar.gz

# set environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 
ENV HADOOP_HOME=/usr/local/hadoop 
ENV PATH=$PATH:/usr/local/hadoop/bin:/usr/local/hadoop/sbin 

# ssh without key
RUN ssh-keygen -t rsa -f ~/.ssh/id_rsa -P '' && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

RUN mkdir -p ~/hdfs/namenode && \ 
    mkdir -p ~/hdfs/datanode && \
    mkdir $HADOOP_HOME/logs

COPY config/* /tmp/

RUN mv /tmp/ssh_config ~/.ssh/config && \
    mv /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    mv /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    mv /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    mv /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    mv /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    mv /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    mv /tmp/workers $HADOOP_HOME/etc/hadoop/workers && \
    mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    mv /tmp/run-wordcount.sh ~/run-wordcount.sh

RUN chmod +x ~/start-hadoop.sh && \
    chmod +x ~/run-wordcount.sh && \
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

ADD install_hive.sh install_hive.sh
ADD hive-site.xml hive-site.xml
RUN bash install_hive.sh && \
	cd /usr/local/hive && \
	echo 1
#	bin/schematool -initSchema -dbType mysql


RUN cd /usr/local && \
	wget https://archive.apache.org/dist/hbase/2.4.0/hbase-2.4.0-bin.tar.gz && \
	tar -xvf hbase-2.4.0-bin.tar.gz && \
	mv hbase-2.4.0 hbase
    
# COPY source/hbase-2.1.0-bin.tar.gz /usr/local/
# RUN cd /usr/local && \
# 	tar -xvf hbase-2.1.0-bin.tar.gz && \
# 	mv hbase-2.1.0 hbase

ADD hbase-env.sh  /usr/local/hbase/conf/hbase-env.sh
ADD hbase-site.xml /usr/local/hbase/conf/hbase-site.xml
ADD regionservers /usr/local/hbase/conf/regionservers
ENV PATH=$PATH:/usr/local/hbase/bin
# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

RUN apt install vim -y

# Install phonenix
RUN wget --no-check-certificate https://dlcdn.apache.org/phoenix/phoenix-5.1.2/phoenix-hbase-2.4.0-5.1.2-bin.tar.gz
RUN tar -xvf phoenix-hbase-2.4.0-5.1.2-bin.tar.gz
RUN mv phoenix-hbase-2.4.0-5.1.2-bin /usr/lib/phoenix
RUN cp /usr/lib/phoenix/phoenix-server-hbase*.jar /usr/local/hbase/lib
ENV PHOENIX_HOME=/usr/lib/phoenix
ENV PATH=$PATH:$PHOENIX_HOME/bin

ENV HADOOP_HOME=/usr/local/hadoop
ENV HBASE_HOME=/usr/local/hbase

ENV HDFS_DATANODE_USER=root
ENV HADOOP_SECURE_DN_USER=hdfs
ENV HDFS_NAMENODE_USER=root
ENV HDFS_SECONDARYNAMENODE_USER=root

ENV YARN_RESOURCEMANAGER_USER=root
ENV HADOOP_SECURE_DN_USER=yarn
ENV YARN_NODEMANAGER_USER=root

ADD start-terminal.sh /root/start-terminal.sh

CMD [ "sh", "-c", "service ssh start; bash start-terminal.sh" ]

