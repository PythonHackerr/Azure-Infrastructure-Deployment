# MySQL version used by the application developers
FROM mysql:8.2.0

ARG DATABASE_MASTER_PORT="3306"
ARG DATABASE_USER="pc"
ARG DATABASE_PASSWORD="pc"
ARG SLAVE_USER_PASSWORD="slave"

RUN echo -e "[mysqld]\nserver-id=1\nlog-bin=mysql-bin\nbinlog_do_db=petclinic\n" >> /etc/mysql/conf.d/mysql.cnf

ENV DB_FILES_URL="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql"

RUN curl "${DB_FILES_URL}/initDB.sql" -o /docker-entrypoint-initdb.d/initDB.sql
RUN curl "${DB_FILES_URL}/populateDB.sql" -o /docker-entrypoint-initdb.d/populateDB.sql
RUN sed -i "s/pc@localhost IDENTIFIED BY 'pc'/'$DATABASE_USER'@'%'/g" /docker-entrypoint-initdb.d/initDB.sql

RUN echo -e "CREATE USER 'slave_user'@'%' IDENTIFIED BY '$SLAVE_USER_PASSWORD'; GRANT REPLICATION SLAVE ON *.* TO 'slave_user'@'%';" >> /docker-entrypoint-initdb.d/createSlaveUser.sql

ENV MYSQL_DATABASE=petclinic \
    MYSQL_USER=$DATABASE_USER \
    MYSQL_PASSWORD=$DATABASE_PASSWORD \
    MYSQL_TCP_PORT=$DATABASE_MASTER_PORT \
    MYSQL_RANDOM_ROOT_PASSWORD=yes

EXPOSE $DATABASE_MASTER_PORT
