#!/bin/bash

#install node
yum -y install npm --enablerepo=epel
rm /usr/bin/npm
ln -s /usr/local/bin/npm /usr/bin/npm
npm install -g n
n latest
rm /usr/bin/node
ln -s /usr/local/bin/node /usr/bin/node
npm install sails forever forever-service -g
ln -s /usr/local/bin/sails /usr/bin/sails
ln -s /usr/local/bin/forever /usr/bin/forever
ln -s /usr/local/bin/forever-service /usr/bin/forever-service

#sudo npm install

#aws configure?
#cd ~/
#aws s3 --region us-east-1 cp s3://cdn.eelrb.com/www/prod/app.js .tmp/prerender/
#aws s3 --region us-east-1 cp s3://cdn.eelrb.com/www/prod/app.manifest.json .tmp/public/
#aws s3 --region us-east-1 cp s3://cdn.eelrb.com/www/prod/app.chunk-manifest.json .tmp/public/
      
#aws s3 --region us-east-1 cp s3://cdn.eelrb.com/www/prod/app_public.js .tmp/prerender/
#aws s3 --region us-east-1 cp s3://cdn.eelrb.com/www/prod/app_public.manifest.json .tmp/public/
#aws s3 --region us-east-1 cp s3://cdn.eelrb.com/www/prod/app_public.chunk-manifest.json .tmp/public/
      
#aws s3 --region us-east-1 cp s3://cdn.eelrb.com/www/prod/i18n .tmp/prerender/i18n/ --recursive
