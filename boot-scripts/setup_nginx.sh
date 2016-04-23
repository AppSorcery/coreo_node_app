#!/bin/bash

coreo_dir="$(pwd)"
files_dir="$(pwd)/../files"

NGINX="/etc/nginx"

sed -i -e "s/\"\$http_x_forwarded_for\"/\"\$http_x_forwarded_for\" \"\$server_port\"/" $NGINX/nginx.conf
sed -i -e "s/include\(.*\)\/etc\/nginx\/conf\.d\/\*\.conf;/include\1\/etc\/nginx\/conf.d\/*.conf;\n    include \/etc\/nginx\/sites-enabled\/*;\n/" $NGINX/nginx.conf

mkdir -p $NGINX/sites-available
mkdir -p $NGINX/sites-enabled
cp "$files_dir/template-nginx-config" "$NGINX/sites-available/$DNS_ZONE.conf"
ln -s "$NGINX/sites-available/$DNS_ZONE.conf" "$NGINX/sites-enabled/$DNS_ZONE.conf"

sed -i -e "s/APP_PORT/$APP_PORT/g" $NGINX/sites-available/$DNS_ZONE.conf
sed -i -e "s/ELB_PROXY_PORT/$ELB_PROXY_PORT/g" $NGINX/sites-available/$DNS_ZONE.conf
sed -i -e "s/ELB_HEALTH_CHECK_PORT/$ELB_HEALTH_CHECK_PORT/g" $NGINX/sites-available/$DNS_ZONE.conf
sed -i -e "s/SERVER_NAME/$DNS_ZONE/g" $NGINX/sites-available/$DNS_ZONE.conf

service nginx restart
/sbin/chkconfig nginx on
