FROM haproxy:1.7.9

LABEL maintainer="Erin Schnabel <schnabel@us.ibm.com> (@ebullientworks)"

ENV ETCD_VERSION 2.2.2

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
     ca-certificates  \
     curl \
     wget \
  && rm -rf /var/lib/apt/lists/* \
  \
# setup etcd
  && wget https://github.com/coreos/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz -q \
  && tar xzf etcd-v${ETCD_VERSION}-linux-amd64.tar.gz etcd-v${ETCD_VERSION}-linux-amd64/etcdctl --strip-components=1 \
  && rm etcd-v${ETCD_VERSION}-linux-amd64.tar.gz \
  && mv etcdctl /usr/local/bin/etcdctl

RUN mkdir -p /run/haproxy \
    mkdir -p /opt/haproxy

COPY ./proxy.pem       /etc/ssl/proxy.pem
COPY ./startup.sh      /opt/startup.sh

# allow local override to work
COPY ./haproxy.cfg     /opt/haproxy/haproxy.cfg
COPY ./haproxy-dev.cfg /opt/haproxy/haproxy-dev.cfg

EXPOSE 80 443 1936

ENTRYPOINT ["/opt/startup.sh"]
CMD [""]
