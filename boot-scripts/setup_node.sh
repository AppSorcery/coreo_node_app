#!/bin/bash

coreo_dir="$(pwd)"

mkdir -p /var/app/current
cd /var/app/current

aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/$APP_ARCHIVE_NAME/$APP_ARCHIVE_NAME.tar.gz .

tar -zxvf $APP_ARCHIVE_NAME.tar.gz
npm install --production

cd $coreo_dir
