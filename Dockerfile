FROM haproxy:1.6

MAINTAINER Ben Smith (benjsmi@us.ibm.com)

RUN apt-get update && apt-get install -y wget ca-certificates --no-install-recommends && rm -rf /var/lib/apt/lists/*

RUN wget -qO- https://github.com/amalgam8/amalgam8/releases/download/v0.3.0/a8sidecar.sh | sh

RUN ln -s /usr/local/etc/haproxy /etc/
RUN mkdir -p /run/haproxy/

RUN wget https://github.com/coreos/etcd/releases/download/v2.2.2/etcd-v2.2.2-linux-amd64.tar.gz -q && \
    tar xzf etcd-v2.2.2-linux-amd64.tar.gz etcd-v2.2.2-linux-amd64/etcdctl --strip-components=1 && \
    rm etcd-v2.2.2-linux-amd64.tar.gz && \
    mv etcdctl /usr/local/bin/etcdctl

COPY ./proxy.pem /etc/ssl/proxy.pem
COPY ./startup.sh /opt/startup.sh

COPY ./haproxy.cfg /etc/haproxy/haproxy.cfg
COPY ./haproxy-ics.cfg /etc/haproxy/haproxy-ics.cfg
COPY ./haproxy-dev.cfg /etc/haproxy/haproxy-dev.cfg

## Logstash-lumberjack is a tcp backend. So we need to enable TCP proxy in nginx
## Hence we override the default nginx config in A8 to include logstash-lumberjack
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./logstash-lumberjack.conf /etc/nginx/logstash-lumberjack.conf

COPY ./amalgam8-services-override.conf /etc/nginx/amalgam8-services.conf
COPY ./amalgam8-access-logging.conf /etc/nginx/amalgam8-access-logging.conf
COPY ./amalgam8-dynupstreams.conf /etc/nginx/amalgam8-dynupstreams.conf

EXPOSE 80 443 1936

ENTRYPOINT ["/opt/startup.sh"]
CMD [""]
