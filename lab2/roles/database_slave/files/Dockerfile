# MySQL version used by the application developers
FROM mysql:8.2.0

ARG DATABASE_SLAVE_PORT
ARG DATABASE_USER
ARG DATABASE_PASSWORD
ARG DATABASE_MASTER_IP
ARG DATABASE_MASTER_PORT
ARG SLAVE_USER_PASSWORD

RUN echo -e "[mysqld]\nserver-id=2\nlog_bin = mysql-bin\nbinlog_do_db = petclinic\n" >> /etc/mysql/conf.d/mysql.cnf

ENV DB_FILES_URL="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql"

RUN curl "${DB_FILES_URL}/initDB.sql" -o /docker-entrypoint-initdb.d/initDB.sql
# populating the database is not necessary for the slave
RUN sed -i "s/pc@localhost IDENTIFIED BY 'pc'/'$DATABASE_USER'@'%'/g" /docker-entrypoint-initdb.d/initDB.sql

RUN echo -e "CHANGE MASTER TO MASTER_HOST='${DATABASE_MASTER_IP}', MASTER_PORT=${DATABASE_MASTER_PORT}, MASTER_USER='slave_user', MASTER_PASSWORD='${SLAVE_USER_PASSWORD}', GET_MASTER_PUBLIC_KEY=1;START SLAVE;" >> /docker-entrypoint-initdb.d/configureReplication.sql

ENV MYSQL_DATABASE=petclinic \
    MYSQL_USER=$DATABASE_USER \
    MYSQL_PASSWORD=$DATABASE_PASSWORD \
    MYSQL_TCP_PORT=$DATABASE_SLAVE_PORT \
    MYSQL_RANDOM_ROOT_PASSWORD=yes

EXPOSE $DATABASE_SLAVE_PORT
