FROM amazoncorretto:17-alpine-jdk

WORKDIR /app

RUN apk add --no-cache git

ARG BACKEND_PORT
ARG DATABASE_MASTER_IP
ARG DATABASE_MASTER_PORT
ARG DATABASE_SLAVE_IP
ARG DATABASE_SLAVE_PORT
ARG DATABASE_USER
ARG DATABASE_PASSWORD

RUN git clone https://github.com/spring-petclinic/spring-petclinic-rest.git .

RUN sed -i "s/=hsqldb/=mysql/g" src/main/resources/application.properties 
RUN sed -i "s/9966/$BACKEND_PORT/g" src/main/resources/application.properties

RUN sed -i "s/jdbc:mysql:\/\/localhost:3306/jdbc:mysql:replication:\/\/$DATABASE_MASTER_IP:$DATABASE_MASTER_PORT,$DATABASE_SLAVE_IP:$DATABASE_SLAVE_PORT/g" ./src/main/resources/application-mysql.properties
RUN sed -i "s/pc/$DATABASE_USER/g" ./src/main/resources/application-mysql.properties
RUN sed -i "s/=petclinic/=$DATABASE_PASSWORD/g" ./src/main/resources/application-mysql.properties

RUN ./mvnw package -DskipTests

EXPOSE $BACKEND_PORT

CMD ["./mvnw", "spring-boot:run"]
