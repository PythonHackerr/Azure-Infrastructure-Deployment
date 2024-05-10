set -e

DATABASE_PORT=$1

MYSQL_CONFIG="/etc/mysql/mysql.conf.d/mysqld.cnf"

sudo sed -i "s/127.0.0.1/0.0.0.0/g" $MYSQL_CONFIG
sudo sed -i "s/3306/$DATABASE_PORT/" $MYSQL_CONFIG
