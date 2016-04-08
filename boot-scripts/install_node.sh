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

aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/$APP_ARCHIVE_NAME.tar.gz .
aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/app.js .tmp/prerender/
aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/app.manifest.json .tmp/public/
aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/app.chunk-manifest.json .tmp/public/
      
aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/app_public.js .tmp/prerender/
aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/app_public.manifest.json .tmp/public/
aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/app_public.chunk-manifest.json .tmp/public/
      
aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/i18n .tmp/prerender/i18n/ --recursive

tar -zxvf $APP_ARCHIVE_NAME.tar.gz
npm install --production

forever-service install $APP_NAME --script app.js -o " $APP_STARTUP_ARGS"
service $APP_NAME start

