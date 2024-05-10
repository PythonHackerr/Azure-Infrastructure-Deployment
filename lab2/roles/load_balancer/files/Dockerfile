FROM nginx

ARG LOAD_BALANCER_PORT="8081"
ARG READ_BACKEND_IP="localhost"
ARG READ_BACKEND_PORT="8082"
ARG WRITE_BACKEND_IP="localhost"
ARG WRITE_BACKEND_PORT="8083"

RUN echo "\
server {\
    listen $LOAD_BALANCER_PORT;\
    location /petclinic/api {\
        proxy_set_header Host \$http_host;\
        proxy_set_header X-Real-IP \$remote_addr;\
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;\
        proxy_set_header X-Forwarded-Proto \$scheme;\
        if (\$request_method = GET) {\
            proxy_pass http://$READ_BACKEND_IP:$READ_BACKEND_PORT;\
        }\
        proxy_pass http://$WRITE_BACKEND_IP:$WRITE_BACKEND_PORT;\
    }\
}" > /etc/nginx/conf.d/default.conf