#!/bin/bash

#
# This script is only intended to run in the IBM DevOps Services Pipeline Environment.
#

echo Informing slack...
#curl -X 'POST' --silent --data-binary '{"text":"A new build for the proxy has started."}' $WEBHOOK > /dev/null
mkdir dockercfg ; cd dockercfg
echo Downloading Docker requirements..
wget http://$BUILD_DOCKER_HOST:8081/dockerneeds.tar -q
echo Setting up Docker...
tar xzf dockerneeds.tar ; mv docker ../ ; cd .. ; chmod +x docker ; \
	export DOCKER_HOST="tcp://$BUILD_DOCKER_HOST:2376" DOCKER_TLS_VERIFY=1 DOCKER_CONFIG=./dockercfg

echo Downloading the certificate...
wget http://$BUILD_DOCKER_HOST:8081/proxy.pem -O ./proxy.pem -q

echo Building the docker image...
./docker build -t gameon-proxy .
echo Stopping the existing container...
./docker stop -t 0 gameon-proxy
./docker rm gameon-proxy
echo Starting the new container...
./docker run -d -p 80:80 -p 443:443 -p 1936:1936 -e LOGGING_DOCKER_HOST=$LOGGING_DOCKER_HOST -e ADMIN_PASSWORD=$ADMIN_PASSWORD -e PROXY_DOCKER_HOST=$PROXY_DOCKER_HOST --name=gameon-proxy gameon-proxy

rm -rf docker-cfg