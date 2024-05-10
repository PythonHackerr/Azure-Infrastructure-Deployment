set -e

DATABASE_MASTER_IP=$1
DATABASE_MASTER_PORT=$2

#cat /etc/mysql/conf.d/mysql.cnf
echo -e "[mysqld]\nbind-address = $DATABASE_MASTER_IP\nport = $DATABASE_MASTER_PORT\nserver-id = 1\nlog_bin = /var/log/mysql/mysql-bin.log\nbinlog_do_db = petclinic\n" | sudo tee /etc/mysql/mysql.conf.d/mysqld.cnf

#sudo sed -i "s/127.0.0.1/$DATABASE_MASTER_IP/g" /etc/mysql/mysql.conf.d/mysqld.cnf
#sudo sed -i "s/3306/$MASTER_PORT/" /etc/mysql/mysql.conf.d/mysqld.cnf
#cat /etc/mysql/conf.d/mysql.cnf
