set -e

DB_FILES_URL=https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql/

DATABASE_USER=$1
DATABASE_PASSWORD=$2
DATABASE_SLAVE_IP=$3
SLAVE_USER_PASSWORD=$4

sudo mysql -e "CREATE USER '$DATABASE_USER'@'%' IDENTIFIED BY '$DATABASE_PASSWORD'; GRANT ALL PRIVILEGES ON *.* TO '$DATABASE_USER'@'%' WITH GRANT OPTION;"
sudo mysql -e "CREATE USER 'slave_user'@'$DATABASE_SLAVE_IP' IDENTIFIED BY '$SLAVE_USER_PASSWORD'; GRANT REPLICATION SLAVE ON *.* TO 'slave_user'@'$DATABASE_SLAVE_IP';"
sudo mysql -e "FLUSH PRIVILEGES;"

wget "$DB_FILES_URL/initDB.sql"
sed -i "s/pc@localhost IDENTIFIED BY 'pc'/'$DATABASE_USER'@'%'/g" initDB.sql
cat initDB.sql | sudo mysql -f

wget "$DB_FILES_URL/populateDB.sql" -O - | sudo mysql petclinic -f