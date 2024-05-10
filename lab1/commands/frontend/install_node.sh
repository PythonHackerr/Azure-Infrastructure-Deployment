set -e

mkdir /tmp/node_install
cd /tmp/node_install
curl -SLO https://deb.nodesource.com/nsolid_setup_deb.sh
chmod +x nsolid_setup_deb.sh
sudo ./nsolid_setup_deb.sh 20
rm nsolid_setup_deb.sh
sudo apt-get install nodejs -y