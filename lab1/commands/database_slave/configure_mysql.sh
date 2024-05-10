set -e

DATABASE_SLAVE_IP=$1
DATABASE_SLAVE_PORT=$2

echo -e "[mysqld]\nbind-address = $DATABASE_SLAVE_IP\nport = $DATABASE_SLAVE_PORT\n\nserver-id=2\nlog_bin = /var/log/mysql/mysql-bin.log\nbinlog_do_db = petclinic\n" | sudo tee /etc/mysql/mysql.conf.d/mysqld.cnf