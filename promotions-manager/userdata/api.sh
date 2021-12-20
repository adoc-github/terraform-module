
echo '==> Installing Node.js and NPM'
apt-get update -y
apt install curl -y
curl -sL https://deb.nodesource.com/setup_10.x | bash -
apt install nodejs -y

apt-get install awscli -y

aws s3 cp s3://${ARTIFACT} promotions-manager-api.master.tar.gz

echo '==> Extract api artifact to /var/promotions-manager-api'
mkdir drop
tar -xvf ./promotions-manager-api.*.tar.gz -C ./drop/
mkdir /var/promotions-manager-api/
tar -xvf ./drop/drop/promotions-manager-api.*.tar.gz -C /var/promotions-manager-api

echo '==> Set the DATABASE_HOST env var to be globally available'
# DATABASE_HOST=$DATABASE_HOST.$DOMAIN_NAME
echo 'DATABASE_HOST='${DATABASE_HOST} >> /etc/environment
echo 'RELEASE_NUMBER='${RELEASE_NUMBER} >> /etc/environment
echo 'API_BUILD_NUMBER='${API_BUILD_NUMBER} >> /etc/environment
echo 'API_PORT='${API_PORT} >> /etc/environment
source /etc/environment

echo '==> Install PM2, it provides an easy way to manage and daemonize nodejs applications'
npm install -g pm2

echo '==> Start our api and configure as a daemon using pm2'
cd /var/promotions-manager-api
pm2 start /var/promotions-manager-api/index.js
pm2 save
chattr +i /root/.pm2/dump.pm2
env PATH=$PATH:/home/unitech/.nvm/versions/node/v4.3/bin pm2 startup systemd -u root --hp /root