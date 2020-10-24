#!/bin/sh

conf_dir=/tmp
src_dir=/tmp/src
cert_dir=/tmp/proxy-cert
mkdir ${src_dir} ${cert_dir}

log() {
  if [ "${GAMEON_LOG_FORMAT}" == "json" ]; then
    # This needs to be escaped using jq
    echo '{"message":"'$@'"}'
  else
    echo $@
  fi
}

log "using /tmp for config"
cp /etc/nginx/nginx.conf ${conf_dir}/nginx.conf

if [ -f /etc/cert/cert.pem ]; then
  cp /etc/cert/cert.pem ${src_dir}/cert.pem
fi

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

  etcdctl get /proxy/third-party-ssl-cert > ${src_dir}/cert.pem
fi

if [ -f ${src_dir}/cert.pem ]; then
  old_dir=$PWD
  cd ${cert_dir}
  awk '/-----BEGIN.*PRIVATE KEY-----/{x=++i}{print > "something"x".pem"}' ${src_dir}/cert.pem
  mv something.pem server.pem
  mv something1.pem private.pem
  cd $old_dir
fi

if [ ! -f ${cert_dir}/server.pem ] || [ ! -f ${cert_dir}/private.pem ] ; then
  log "Unable to find certificate"
  exit 1
fi

if [ "${GAMEON_LOG_FORMAT}" == "json" ]; then
  sed -i -e "s/access\.log .*$/access.log json_combined;/" ${conf_dir}/nginx.conf
else
  sed -i -e "s/access\.log .*$/access.log combined;/" ${conf_dir}/nginx.conf
fi

log "Init complete. Starting nginx"
exec nginx -c ${conf_dir}/nginx.conf
