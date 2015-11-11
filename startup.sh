#!/bin/bash

echo Replacing password in...
sed -i s/PLACEHOLDER_PASSWORD/$ADMIN_PASSWORD/g /etc/haproxy/haproxy.cfg
sed -i s/PLACEHOLDER_DOCKERHOST/$PROXY_DOCKER_HOST/g /etc/haproxy/haproxy.cfg
echo Starting rsyslog...
service rsyslog start
echo Starting haproxy-- background mode.
haproxy -f /etc/haproxy/haproxy.cfg
echo Starting the log forwarder...
cd /opt ; ./forwarder --config ./forwarder.conf