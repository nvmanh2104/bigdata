cd /usr/local
wget https://mirror.downloadvn.com/apache/hive/stable-2/apache-hive-2.3.9-bin.tar.gz

tar zxvf apache-hive-2.3.9-bin.tar.gz
mv apache-hive-2.3.9-bin hive

echo 'export HIVE_HOME="/usr/local/hive"' >> ~/.bashrc
echo 'export HCAT_HOME=$HIVE_HOME/hcatalog' >> ~/.bashrc
echo 'export PATH=$PATH:$HIVE_HOME/bin' >> ~/.bashrc

cd hive
cp conf/hive-env.sh.template conf/hive-env.sh
echo 'export HADOOP_HOME="/usr/local/hadoop"' >> /usr/local/hive/hive-env.sh

cp ~/hive-site.xml /usr/local/hive/conf

cd /usr/local/hive
wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-8.0.23.tar.gz
tar xvf mysql-connector-java-8.0.23.tar.gz
cd mysql-connector-java-8.0.23
cp mysql-connector-java-8.0.23.jar /usr/local/hive/lib/
