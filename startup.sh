#!/bin/sh

# Configure our link to etcd based on shared volume with secret
if [ ! -z "$ETCD_SECRET" ]; then
  . /data/primordial/setup.etcd.sh /data/primordial $ETCD_SECRET
fi

log() {
  if [ "${GAMEON_LOG_FORMAT}" == "json" ]; then
    # This needs to be escaped using jq
    echo '{"message":"'$1'"}'
  else
    echo $1
  fi
}

if [ "$ETCDCTL_ENDPOINT" != "" ]; then
  log Setting up etcd...
  local RC=1
  local count=0
  while [ $RC -ne 0 ]; do
    if [ $count -gt 15 ]; then
      log "Unable to reach etcd"
      exit 1
    fi

    log "** Testing etcd is accessible"
    etcdctl --debug ls
    RC=$?
    if [ $RC -ne 0 ]; then
      sleep 15
      ((count++))
    fi
  done
  log "etcdctl returned sucessfully, continuing"

  etcdctl get /proxy/cert > /etc/cert/cert.pem
fi

if [ ! -f /etc/cert/cert.pem ]; then
  log "Unable to find certificate /etc/cert/cert.pem"
  exit 1
fi

if [ ! -f /etc/cert/private.pem ]; then
  awk '/-----BEGIN PRIVATE KEY-----/{x=++i}{print > "something"x".pem"}' /etc/cert/cert.pem
  mv something.pem /etc/cert/server.pem
  mv something1.pem /etc/cert/private.pem
  find /etc/cert/
fi

if [ "${GAMEON_LOG_FORMAT}" == "json" ]; then
  sed -i -e "s/access\.log .*$/access.log json_combined;/" /etc/nginx/nginx.conf
else
  sed -i -e "s/access\.log .*$/access.log combined;/" /etc/nginx/nginx.conf
fi

exec nginx
