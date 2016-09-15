#!/bin/bash

export A8_SERVICE=proxy

if [ "$ETCDCTL_ENDPOINT" != "" ]; then
  if [ "$PROXY_CONFIG" == "" ]; then
    PROXY_CONFIG=/etc/haproxy/haproxy.cfg
  fi
  echo Setting up etcd...
  echo "** Testing etcd is accessible"
  etcdctl --debug ls
  RC=$?

  while [ $RC -ne 0 ]; do
      sleep 15

      # recheck condition
      echo "** Re-testing etcd connection"
      etcdctl --debug ls
      RC=$?
  done
  echo "etcdctl returned sucessfully, continuing"

  echo "Using config file $PROXY_CONFIG"

  etcdctl get /proxy/third-party-ssl-cert > /etc/ssl/proxy.pem
  sed -i s/PLACEHOLDER_PASSWORD/$(etcdctl get /passwords/admin-password)/g /etc/haproxy/haproxy.cfg
  sed -i s/PLACEHOLDER_DOCKERHOST/$(etcdctl get /proxy/docker-host)/g /etc/haproxy/haproxy.cfg
  sed -i s/PLACEHOLDER_LOGHOST/$(etcdctl get /logstash/endpoint)/g /etc/haproxy/haproxy.cfg


  export ROOM_ENDPOINT=$(etcdctl get /endpoints/room)
  export MAP_ENDPOINT=$(etcdctl get /endpoints/map)
  export MEDIATOR_ENDPOINT=$(etcdctl get /endpoints/mediator)
  export PLAYER_ENDPOINT=$(etcdctl get /endpoints/player)
  export WEBAPP_ENDPOINT=$(etcdctl get /endpoints/webapp)
  export SWAGGER_ENDPOINT=$(etcdctl get /endpoints/swagger)

  sudo service rsyslog start 

  echo Starting haproxy...
  haproxy -f $PROXY_CONFIG
  echo HAProxy shut down
else
  echo HAProxy will log to STDOUT--this is dev environment.
  sed -i s/PLACEHOLDER_PASSWORD/$ADMIN_PASSWORD/g /etc/haproxy/haproxy-dev.cfg
  exec a8sidecar --log --proxy
fi
