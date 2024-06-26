# FROM ubuntu:14.04
FROM ubuntu:18.04

MAINTAINER manh.ngovan <manh.ngovan@gmail.com>

WORKDIR /root

RUN apt-get update && apt-get install software-properties-common -y
RUN add-apt-repository ppa:deadsnakes/ppa -y
RUN apt install python3.7 -y
RUN apt install python3-pip -y 
RUN pip3 install pip -U

RUN add-apt-repository ppa:openjdk-r/ppa

# install openssh-server, openjdk and wget
RUN apt-get install -y openssh-server openjdk-8-jdk wget
RUN apt install nano curl net-tools iputils-ping lsof unzip -y

# install hadoop 2.7.2
# RUN wget https://github.com/kiwenlau/compile-hadoop/releases/download/2.7.2/hadoop-2.7.2.tar.gz  && \
#     tar -xzvf hadoop-2.7.2.tar.gz && \
#     mv hadoop-2.7.2 /usr/local/hadoop && \
#     rm hadoop-2.7.2.tar.gz

COPY bigdata-resource/* /tmp/
COPY bigdata-resource/jdbc/*.jar /tmp/jdbc/

RUN cd /tmp && \
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

RUN cp -f /tmp/ssh_config ~/.ssh/config && \
    cp -f /tmp/hadoop-env.sh /usr/local/hadoop/etc/hadoop/hadoop-env.sh && \
    cp -f /tmp/hdfs-site.xml $HADOOP_HOME/etc/hadoop/hdfs-site.xml && \ 
    cp -f /tmp/core-site.xml $HADOOP_HOME/etc/hadoop/core-site.xml && \
    cp -f /tmp/mapred-site.xml $HADOOP_HOME/etc/hadoop/mapred-site.xml && \
    cp -f /tmp/yarn-site.xml $HADOOP_HOME/etc/hadoop/yarn-site.xml && \
    cp -f /tmp/slaves $HADOOP_HOME/etc/hadoop/slaves && \
    cp -f /tmp/workers $HADOOP_HOME/etc/hadoop/workers && \
    #mv /tmp/start-hadoop.sh ~/start-hadoop.sh && \
    cp -f /tmp/run-wordcount.sh ~/run-wordcount.sh

RUN chmod +x ~/run-wordcount.sh && \
    #chmod +x ~/start-hadoop.sh && \    
    chmod +x $HADOOP_HOME/sbin/start-dfs.sh && \
    chmod +x $HADOOP_HOME/sbin/start-yarn.sh 

ADD install_hive.sh install_hive.sh
#ADD hive-site.xml hive-site.xml
RUN bash install_hive.sh && \
	cd /usr/local/hive && \
	echo 1
#	bin/schematool -initSchema -dbType mysql


RUN cd /tmp && \	
	tar -xvf hbase-2.4.0-bin.tar.gz && \
	mv hbase-2.4.0 /usr/local/hbase && \
    rm hbase-2.4.0-bin.tar.gz
    
# COPY source/hbase-2.1.0-bin.tar.gz /usr/local/
# RUN cd /usr/local && \
# 	tar -xvf hbase-2.1.0-bin.tar.gz && \
# 	mv hbase-2.1.0 hbase

RUN cp -f /tmp/hbase-env.sh  /usr/local/hbase/conf/hbase-env.sh
RUN cp -f /tmp/hbase-site.xml /usr/local/hbase/conf/hbase-site.xml
RUN cp -f /tmp/regionservers /usr/local/hbase/conf/regionservers
RUN cp -f /tmp/backup-masters /usr/local/hbase/conf/backup-masters
RUN cp -f /tmp/hdfs-site.xml /usr/local/hbase/conf/hdfs-site.xml
ENV PATH=$PATH:/usr/local/hbase/bin
# HA folder shared
RUN mkdir -p /mnt/dfs/ha-name-dir-shared
# format namenode
RUN /usr/local/hadoop/bin/hdfs namenode -format

# Install phonenix
RUN cd /tmp && \
 tar -xvf phoenix-hbase-2.4.0-5.1.2-bin.tar.gz && \
 mv phoenix-hbase-2.4.0-5.1.2-bin /usr/lib/phoenix && \
 cp /usr/lib/phoenix/phoenix-server-hbase*.jar /usr/local/hbase/lib && \
 rm phoenix-hbase-2.4.0-5.1.2-bin.tar.gz

ENV PHOENIX_HOME=/usr/lib/phoenix
ENV PATH=$PATH:$PHOENIX_HOME/bin
# Install phonenix query server
# RUN cd /tmp && \
#  tar -xvf phoenix-queryserver-6.0.0-bin.tar.gz && \
#  mv phoenix-queryserver-6.0.0 /usr/lib/phoenix-queryserver && \
#  cp /usr/lib/phoenix-queryserver/phoenix-queryserver*.jar /usr/local/hbase/lib && \
#  rm phoenix-queryserver-6.0.0-bin.tar.gz
# ENV PHOENIX_QUERYSERVER=/usr/lib/phoenix-queryserver
# ENV PATH=$PATH:$PHOENIX_QUERYSERVER/bin
# ENV PATH=$PATH:/usr/local/hbase/lib
# Install Zookeeper
# RUN mkdir -p /opt/zookeeper
# RUN mkdir -p /data/zookeeper
# RUN wget --no-check-certificate https://archive.apache.org/dist/zookeeper/zookeeper-3.4.9/zookeeper-3.4.9.tar.gz
# RUN tar xvzf zookeeper-3.4.9.tar.gz  --directory /opt/zookeeper --strip-components 1
# RUN rm -rf zookeeper-3.4.9.tar.gz
# RUN mv /tmp/zoo.cfg /opt/zookeeper/conf/zoo.cfg
# RUN mv /tmp/zk.service /etc/systemd/system/zk.service
# ENV ZOOKEEPER_HOME=/opt/zookeeper
# ENV ZOOKEEPER_DATA=/data/zookeeper

# Install Spark
RUN mkdir -p /usr/local/spark
ARG SPARK_VERSION=3.4.3
RUN cd /tmp && \
 tar xvzf spark-${SPARK_VERSION}-bin-hadoop3.tgz --directory /usr/local/spark --strip-components 1 && \
 rm -rf spark-${SPARK_VERSION}-bin-hadoop3.tgz
COPY requirements.txt .
#RUN pip3 install -r requirements.txt

ENV PATH="/usr/local/spark/sbin:/usr/local/spark/bin:${PATH}"
ENV SPARK_HOME=/usr/local/spark
ENV SPARK_MASTER="spark://hadoop-master1:7077"
ENV SPARK_MASTER_HOST hadoop-master1
ENV SPARK_MASTER_PORT 7077
ENV PYSPARK_PYTHON python3
RUN mv /tmp/spark-defaults.conf $SPARK_HOME/conf
RUN chmod u+x /usr/local/spark/sbin/* && \
    chmod u+x /usr/local/spark/bin/*
ENV PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH

# Install NiFI
ARG NIFI_VERSION=1.25.0
RUN cd /tmp \
 && unzip  nifi-${NIFI_VERSION}-bin.zip -d /usr/local/ \
 && rm -rf nifi-${NIFI_VERSION}-bin.zip
RUN cd /usr/local/nifi-${NIFI_VERSION} \
&& bin/nifi.sh install
RUN mv /tmp/nifi.properties /usr/local/nifi-${NIFI_VERSION}/conf
RUN mv /tmp/state-management.xml /usr/local/nifi-${NIFI_VERSION}/conf
RUN mv /tmp/login-identity-providers.xml /usr/local/nifi-${NIFI_VERSION}/conf
# Install NiFi tookit
RUN cd /tmp \
&& unzip  nifi-toolkit-1.25.0-bin.zip -d /usr/local/nifi-${NIFI_VERSION} \
&& rm -rf nifi-toolkit-1.25.0-bin.zip
RUN cd /usr/local/nifi-${NIFI_VERSION}/nifi-toolkit-1.25.0 \
&& bin/tls-toolkit.sh standalone -n '0.0.0.0' -C 'CN=kttv,OU=NIFI'
# JDBC LIBS
RUN mkdir -p /usr/local/jdbc-libs
RUN cp -f /tmp/jdbc/*.jar /usr/local/jdbc-libs/
    # hive lib
RUN cp -f /tmp/jdbc/*.jar /usr/local/hive/lib/
    # nifi lib
RUN cp -f /tmp/jdbc/*.jar /usr/local/nifi-${NIFI_VERSION}/lib/
# Environment
ENV HADOOP_HOME=/usr/local/hadoop
ENV HBASE_HOME=/usr/local/hbase

ENV HDFS_DATANODE_USER=root
ENV HADOOP_SECURE_DN_USER=hdfs
ENV HDFS_NAMENODE_USER=root
ENV HDFS_SECONDARYNAMENODE_USER=root

ENV YARN_RESOURCEMANAGER_USER=root
ENV HADOOP_SECURE_DN_USER=yarn
ENV YARN_NODEMANAGER_USER=root

ENV HDFS_ZKFC_USER=root

RUN mv /tmp/spark-ha.conf /root/spark-ha.conf
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]

# WORKDIR  /home/
# ADD start-terminal.sh /home/start-terminal.sh
# CMD [ "sh", "start-terminal.sh" ]

