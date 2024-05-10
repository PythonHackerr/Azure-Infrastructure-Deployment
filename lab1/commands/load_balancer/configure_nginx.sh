set -e

LOAD_BALANCER_PORT=$1
READ_BACKEND_IP=$2
READ_BACKEND_PORT=$3
WRITE_BACKEND_IP=$4
WRITE_BACKEND_PORT=$5

cd ~

cat > petclinic_balancer.conf << EOL
map \$request_method \$upstream_location {
    GET     $READ_BACKEND_IP:$READ_BACKEND_PORT;
    default $WRITE_BACKEND_IP:$WRITE_BACKEND_PORT;
}
server {
    listen $LOAD_BALANCER_PORT;
    location /petclinic/api {
        proxy_pass https://\$upstream_location;
    }
}
EOL
sudo cp petclinic_balancer.conf /etc/nginx/conf.d/
sudo rm -f /etc/nginx/sites-enabled/default