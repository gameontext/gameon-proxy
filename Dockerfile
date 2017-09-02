FROM haproxy:1.7.9

LABEL maintainer="Erin Schnabel <schnabel@us.ibm.com> (@ebullientworks)"

RUN apt-get update \
  && apt-get install -y wget ca-certificates --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/haproxy \
    mkdir -p /opt/haproxy

RUN wget https://github.com/coreos/etcd/releases/download/v2.2.2/etcd-v2.2.2-linux-amd64.tar.gz -q && \
    tar xzf etcd-v2.2.2-linux-amd64.tar.gz etcd-v2.2.2-linux-amd64/etcdctl --strip-components=1 && \
    rm etcd-v2.2.2-linux-amd64.tar.gz && \
    mv etcdctl /usr/local/bin/etcdctl

COPY ./proxy.pem       /etc/ssl/proxy.pem
COPY ./startup.sh      /opt/startup.sh

# allow local override to work
COPY ./haproxy.cfg     /opt/haproxy/haproxy.cfg
COPY ./haproxy-dev.cfg /opt/haproxy/haproxy-dev.cfg

EXPOSE 80 443 1936

ENTRYPOINT ["/opt/startup.sh"]
CMD [""]
