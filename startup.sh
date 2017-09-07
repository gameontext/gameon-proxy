#!/bin/bash

# Configure our link to etcd based on shared volume with secret
if [ ! -z "$ETCD_SECRET" ]; then
  . /data/primordial/setup.etcd.sh /data/primordial $ETCD_SECRET
fi


if [ "$ETCDCTL_ENDPOINT" != "" ]; then
  if [ "$PROXY_CONFIG" == "" ]; then
    PROXY_CONFIG=/opt/haproxy/haproxy.cfg
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

  sed -i s/PLACEHOLDER_PASSWORD/$(etcdctl get /passwords/admin-password)/g /opt/haproxy/haproxy.cfg

  export SLACKIN_ENDPOINT=$(etcdctl get /endpoints/slackin)

  sudo service rsyslog start
else
  if [ "$PROXY_CONFIG" == "" ]; then
    PROXY_CONFIG=/opt/haproxy/haproxy-dev.cfg
  fi

  sed -i s/PLACEHOLDER_PASSWORD/$ADMIN_PASSWORD/g /opt/haproxy/haproxy-dev.cfg
fi

echo Starting haproxy...
exec /docker-entrypoint.sh -f $PROXY_CONFIG
