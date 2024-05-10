set -e

FRONTEND_PORT=$1
BACKEND_IP=$2
BACKEND_PORT=$3

cd ~/spring-petclinic-angular

sudo mkdir -p /usr/share/nginx/html/petclinic
sudo cp -r dist/ /usr/share/nginx/html/petclinic

cat > petclinic.conf << EOL
server {
	listen $FRONTEND_PORT default_server;
    root /usr/share/nginx/html;
    index /petclinic/index.html;

	location / {
        alias /usr/share/nginx/html/petclinic/dist/;
        try_files \$uri\$args \$uri\$args/ /index.html;
    }

    location /petclinic/api/ {
        proxy_pass http://${BACKEND_IP}:${BACKEND_PORT};
        include proxy_params;
    }
}
EOL
sudo cp petclinic.conf /etc/nginx/conf.d/
sudo rm -f /etc/nginx/sites-enabled/default
