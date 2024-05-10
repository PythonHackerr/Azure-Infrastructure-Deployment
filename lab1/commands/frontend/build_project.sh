set -e

PUBLIC_IP=$1
FRONTEND_PORT=$2

cd ~/spring-petclinic-angular
sed -i "s/localhost:9966/$PUBLIC_IP:$FRONTEND_PORT/g" src/environments/environment.ts # petclinic uses development enviroment in production mode
npm run build --prod