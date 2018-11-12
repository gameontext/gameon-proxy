#!/bin/sh

log() {
  if [ "${GAMEON_LOG_FORMAT}" == "json" ]; then
    # This needs to be escaped using jq
    echo '{"message":"'$@'"}'
  else
    echo $@
  fi
}

if [ "$ETCDCTL_ENDPOINT" != "" ]; then
  log "Setting up etcd..."
  etcdctl --debug ls
  RC=$?
  while [ $RC -ne 0 ]; do
      sleep 15
      # recheck condition
      log "** Re-testing etcd connection"
      etcdctl --debug ls
      RC=$?
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

log "Init complete. Starting nginx"
exec nginx
