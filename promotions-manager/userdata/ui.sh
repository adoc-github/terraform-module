#!/bin/bash
echo '=============== Staring init script for Promotions Manager UI ==============='


echo '==> Installing Node.js and NPM'
apt-get update
apt install curl -y
curl -sL https://deb.nodesource.com/setup_10.x | bash -
apt install nodejs

echo '==> Install nginx'
apt-get install nginx -y

apt-get install awscli -y

aws s3 cp s3://${ARTIFACT} promotions-manager-ui.master.tar.gz

echo '==> Extract ui artifact to /var/www/promotions-manager/'
# mkdir $ARTIFACTS_PATH/drop
# tar -xvf $ARTIFACTS_PATH/promotions-manager-ui.*.tar.gz -C $ARTIFACTS_PATH/drop/
mkdir /var/www/promotions-manager/
# cp -R $ARTIFACTS_PATH/drop/build/* /var/www/promotions-manager/ 
# $ARTIFACTS_PATH == */drop/drop/*
tar -xvf ./promotions-manager-ui.*.tar.gz -C /var/www/promotions-manager/
tar -xvf /var/www/promotions-manager/drop/promotions-manager-ui.*.tar.gz -C /var/www/promotions-manager/
cp -R /var/www/promotions-manager/build/* /var/www/promotions-manager/ 


echo '==> Configure nginx'
cd /etc/nginx/sites-available/
cp default default.backup

cat << EOF > ./default
server {
	listen ${PORT} default_server;
	listen [::]:${PORT} default_server;
	root /var/www/promotions-manager;
	server_name _;
	index index.html index.htm;
	location /api {		
		proxy_pass http://${API_URL};
		proxy_http_version 1.1;
		proxy_set_header Upgrade \$http_upgrade;
		proxy_set_header Connection 'upgrade';
		proxy_set_header Host \$host;
		proxy_cache_bypass \$http_upgrade;
		proxy_read_timeout 600s;
	}
	location / {
		try_files \$uri /index.html;
	}
}
EOF

service nginx restart