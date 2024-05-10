set -e

BACKEND_PORT=$1
DATABASE_MASTER_IP=$2
DATABASE_MASTER_PORT=$3
DATABASE_SLAVE_IP=$4
DATABASE_SLAVE_PORT=$5
DATABASE_USER=$6
DATABASE_PASSWORD=$7

cd ~/spring-petclinic-rest

sed -i "s/=hsqldb/=mysql/g" src/main/resources/application.properties 
sed -i "s/9966/$BACKEND_PORT/g" src/main/resources/application.properties

sed -i "s/jdbc:mysql:\/\/localhost:3306/jdbc:mysql:replication:\/\/$DATABASE_MASTER_IP:$DATABASE_MASTER_PORT,$DATABASE_SLAVE_IP:$DATABASE_SLAVE_PORT/g" ./src/main/resources/application-mysql.properties
sed -i "s/pc/$DATABASE_USER/g" ./src/main/resources/application-mysql.properties
sed -i "s/=petclinic/=$DATABASE_PASSWORD/g" ./src/main/resources/application-mysql.properties
