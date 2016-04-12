# set $ELB_PROXY_PORT port on elb to proxy

cd
files_dir="$(pwd)/../files"
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


sed -i -e "s/include\(.*\)\/etc\/nginx\/conf\.d\/\*\.conf;/include\1\/etc\/nginx\/*.conf;\n    include \/etc\/nginx\/sites-enabled\/*;\n/" $NGINX/nginx.conf
mkdir -p $NGINX/sites-enabled
cp "$files_dir/template-nginx-config" "$NGINX/sites-enabled/$DNS_ZONE.conf"

sed -i -e "s/APP_PORT/$APP_PORT" -e "s/ELB_PROXY_PORT/$ELB_PROXY_PORT" -e "s/SERVER_NAME/$DNS_ZONE" $NGINX/sites-enabled/$DNS_ZONE.conf
