FROM node:20-alpine as build-stage

ARG PUBLIC_IP="localhost"
ARG FRONTEND_PORT="8080"

RUN apk add --no-cache nginx git

WORKDIR /app

RUN git clone https://github.com/spring-petclinic/spring-petclinic-angular.git .

RUN npm install -g @angular/cli@latest

RUN npm install

RUN sed -i "s/localhost:9966/$PUBLIC_IP:$FRONTEND_PORT/g" src/environments/environment.ts
RUN npm run build --prod

FROM nginx

ARG FRONTEND_PORT="8080"
ARG BACKEND_IP="localhost"
ARG BACKEND_PORT="9966"

COPY --from=build-stage /app/dist /usr/share/nginx/html/petclinic/

RUN echo "\ 
server {\
	listen $FRONTEND_PORT default_server;\
    root /usr/share/nginx/html/petclinic;\
    index /index.html;\
\
    location / {\
        try_files \$uri \$uri/ /index.html;\
    }\
\
    location /petclinic/api/ {\
        proxy_set_header Host \$http_host;\
        proxy_set_header X-Real-IP \$remote_addr;\
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\
        proxy_set_header X-Forwarded-Proto \$scheme;\
        proxy_pass http://$BACKEND_IP:$BACKEND_PORT;\
    }\
}" > /etc/nginx/conf.d/default.conf

EXPOSE $FRONTEND_PORT