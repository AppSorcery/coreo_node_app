#!/bin/bash

ELB_NAME=${ELB_NAME/internal-/}
ELB_NAME=${ELB_NAME/private-/}
ELB_NAME=($(echo $ELB_NAME | sed 's/-elb-.*/-elb/'))

if [ -z "${ELB_PROXY_PORT:-}" ]; then
    ELB_PROXY_PORT=80
fi

if [ -z "${ELB_SSL_PROXY_PORT:-}" ]; then
    ELB_SSL_PROXY_PORT=443
fi

aws elb create-load-balancer-policy --region $REGION --load-balancer-name $ELB_NAME --policy-name $APP_NAME-elb --policy-type-name ProxyProtocolPolicyType --policy-attributes AttributeName=ProxyProtocol,AttributeValue=true
aws elb set-load-balancer-policies-for-backend-server --region $REGION --load-balancer-name $ELB_NAME --instance-port $ELB_PROXY_PORT --policy-names $APP_NAME-elb
aws elb set-load-balancer-policies-for-backend-server --region $REGION --load-balancer-name $ELB_NAME --instance-port $ELB_SSL_PROXY_PORT --policy-names $APP_NAME-elb
aws elb describe-load-balancers --region $REGION --load-balancer-name $ELB_NAME
