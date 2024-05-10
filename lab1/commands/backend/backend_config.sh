set -e

BACKEND_PORT=$1
DATABASE_IP=$2
DATABASE_PORT=$3
DATABASE_USER=$4
DATABASE_PASSWORD=$5

cd ~/spring-petclinic-rest

sed -i "s/=hsqldb/=mysql/g" src/main/resources/application.properties 
sed -i "s/9966/$BACKEND_PORT/g" src/main/resources/application.properties

sed -i "s/localhost/$DATABASE_IP/g" ./src/main/resources/application-mysql.properties
sed -i "s/3306/$DATABASE_PORT/g" ./src/main/resources/application-mysql.properties
sed -i "s/pc/$DATABASE_USER/g" ./src/main/resources/application-mysql.properties
sed -i "s/=petclinic/=$DATABASE_PASSWORD/g" ./src/main/resources/application-mysql.properties
