#!/bin/bash

#install node
yum -y install npm --enablerepo=epel
npm install -g n
n latest
rm /usr/bin/npm
ln -s /usr/local/bin/npm /usr/bin/npm
rm /usr/bin/node
ln -s /usr/local/bin/node /usr/bin/node
npm install sails forever forever-service -g
ln -s /usr/local/bin/sails /usr/bin/sails
ln -s /usr/local/bin/forever /usr/bin/forever
ln -s /usr/local/bin/forever-service /usr/bin/forever-service

mkdir -p /var/app/current
cd /var/app/current

aws s3 --region us-east-1 cp s3://cdn.eelrb.com/www/dev/dev.zip .
aws s3 --region us-east-1 cp s3://cdn.eelrb.com/www/dev/app.js .tmp/prerender/
aws s3 --region us-east-1 cp s3://cdn.eelrb.com/www/dev/app.manifest.json .tmp/public/
aws s3 --region us-east-1 cp s3://cdn.eelrb.com/www/dev/app.chunk-manifest.json .tmp/public/
      
aws s3 --region us-east-1 cp s3://cdn.eelrb.com/www/dev/app_public.js .tmp/prerender/
aws s3 --region us-east-1 cp s3://cdn.eelrb.com/www/dev/app_public.manifest.json .tmp/public/
aws s3 --region us-east-1 cp s3://cdn.eelrb.com/www/dev/app_public.chunk-manifest.json .tmp/public/
      
aws s3 --region us-east-1 cp s3://cdn.eelrb.com/www/dev/i18n .tmp/prerender/i18n/ --recursive

unzip dev.zip
tar -xvf dev.tar
npm install --production

#forever-service install dev2
