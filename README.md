# bigdata

mssql

wget https://download.microsoft.com/download/9/e/9/9e97cef4-4c64-484c-bd1b-192147912c47/enu/sqljdbc_12.6.1.0_enu.tar.gz
tar xvf sqljdbc_12.6.1.0_enu.tar.gz
cp sqljdbc_12.6/enu/jars/mssql-jdbc-12.6.1.jre8.jar /usr/local/hive/lib/

mysql:
cp /usr/local/hive/lib/mysql-connector-java-8.0.23.jar 

postgre:
https://jdbc.postgresql.org/download/postgresql-42.6.2.jar

oracle: https://download.oracle.com/otn-pub/otn_software/jdbc/233/ojdbc8.jar

bin/nifi.sh run - Launches the application to run in the foreground

bin/nifi.sh start - Launches the application to run the background

bin/nifi.sh status - Check the status

bin/nifi.sh stop - Shutdown the application