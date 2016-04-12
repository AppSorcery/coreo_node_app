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

aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/$APP_ARCHIVE_NAME/$APP_ARCHIVE_NAME.tar.gz .
aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/$APP_ARCHIVE_NAME/app.js .tmp/prerender/
aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/$APP_ARCHIVE_NAME/app.manifest.json .tmp/public/
aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/$APP_ARCHIVE_NAME/app.chunk-manifest.json .tmp/public/
      
aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/$APP_ARCHIVE_NAME/app_public.js .tmp/prerender/
aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/$APP_ARCHIVE_NAME/app_public.manifest.json .tmp/public/
aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/$APP_ARCHIVE_NAME/app_public.chunk-manifest.json .tmp/public/
      
aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/$APP_ARCHIVE_NAME/i18n .tmp/prerender/i18n/ --recursive

aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/$APP_ARCHIVE_NAME/favicon .tmp/public --recursive
aws s3 --region $APP_BUCKET_REGION cp s3://$APP_BUCKET/$APP_BUCKET_PATH/$APP_ARCHIVE_NAME/sails.io.js .tmp/public/

tar -zxvf $APP_ARCHIVE_NAME.tar.gz
npm install --production

echo "ELB_NAME: $ELB_NAME"
ELB_NAME=${ELB_NAME/internal-/}
ELB_NAME=${ELB_NAME/private-/}
ELB_NAME=($(echo $ELB_NAME | sed 's/-elb-.*/-elb/'))
echo "ELB_NAME: $ELB_NAME"

aws elb describe-load-balancers --region us-east-1 --load-balancer-name $ELB_NAME
aws elb create-load-balancer-policy --region us-east-1 --load-balancer-name $ELB_NAME --policy-name $APP_NAME-elb --policy-type-name ProxyProtocolPolicyType --policy-attributes AttributeName=ProxyProtocol,AttributeValue=true
aws elb set-load-balancer-policies-for-backend-server --region us-east-1 --load-balancer-name $ELB_NAME --instance-port 80 --policy-names $APP_NAME-elb
aws elb describe-load-balancers --region us-east-1 --load-balancer-name $ELB_NAME

echo "forever-service install $APP_NAME --script app.js -o \" $APP_STARTUP_ARGS\""
forever-service install $APP_NAME --script app.js -o " $APP_STARTUP_ARGS"
service $APP_NAME start

