# MySQL version used by the application developers
FROM mysql:8.2.0

ARG DATABASE_PORT="3306"
ARG DATABASE_USER="pc"
ARG DATABASE_PASSWORD="pc"

ENV DB_FILES_URL="https://raw.githubusercontent.com/spring-petclinic/spring-petclinic-rest/master/src/main/resources/db/mysql"

RUN curl "${DB_FILES_URL}/initDB.sql" -o /docker-entrypoint-initdb.d/initDB.sql
RUN curl "${DB_FILES_URL}/populateDB.sql" -o /docker-entrypoint-initdb.d/populateDB.sql
RUN sed -i "s/pc@localhost IDENTIFIED BY 'pc'/'$DATABASE_USER'@'%'/g" /docker-entrypoint-initdb.d/initDB.sql

ENV MYSQL_DATABASE=petclinic \
    MYSQL_USER=$DATABASE_USER \
    MYSQL_PASSWORD=$DATABASE_PASSWORD \
    MYSQL_TCP_PORT=$DATABASE_PORT \
    MYSQL_RANDOM_ROOT_PASSWORD=yes

EXPOSE $DATABASE_PORT
