#!/bin/bash

coreo_dir="$(pwd)"
files_dir="$(pwd)/../files"

#install node
yum -y install nginx --enablerepo=epel
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

echo "forever-service install $APP_NAME --script app.js -o \" $APP_STARTUP_ARGS\""
forever-service install $APP_NAME --script app.js -o " $APP_STARTUP_ARGS"
service $APP_NAME start

# set $ELB_PROXY_PORT port on elb to proxy

NGINX="/etc/nginx"

ELB_NAME=${ELB_NAME/internal-/}
ELB_NAME=${ELB_NAME/private-/}
ELB_NAME=($(echo $ELB_NAME | sed 's/-elb-.*/-elb/'))

if [ -z "${ELB_PROXY_PORT:-}" ]; then
    ELB_PROXY_PORT=80
fi

aws elb create-load-balancer-policy --region $REGION --load-balancer-name $ELB_NAME --policy-name $APP_NAME-elb --policy-type-name ProxyProtocolPolicyType --policy-attributes AttributeName=ProxyProtocol,AttributeValue=true
aws elb set-load-balancer-policies-for-backend-server --region $REGION --load-balancer-name $ELB_NAME --instance-port $ELB_PROXY_PORT --policy-names $APP_NAME-elb
aws elb describe-load-balancers --region $REGION --load-balancer-name $ELB_NAME


sed -i -e "s/include\(.*\)\/etc\/nginx\/conf\.d\/\*\.conf;/include\1\/etc\/nginx\/conf.d\/*.conf;\n    include \/etc\/nginx\/sites-enabled\/*;\n/" $NGINX/nginx.conf
mkdir -p $NGINX/sites-available
mkdir -p $NGINX/sites-enabled
cp "$files_dir/template-nginx-config" "$NGINX/sites-available/$DNS_ZONE.conf"
ln -s "$NGINX/sites-available/$DNS_ZONE.conf" "$NGINX/sites-enabled/$DNS_ZONE.conf"

sed -i -e "s/APP_PORT/$APP_PORT/" $NGINX/sites-available/$DNS_ZONE.conf
sed -i -e "s/ELB_PROXY_PORT/$ELB_PROXY_PORT/" $NGINX/sites-available/$DNS_ZONE.conf
sed -i -e "s/SERVER_NAME/*.$DNS_ZONE/" $NGINX/sites-available/$DNS_ZONE.conf

service nginx restart

