FROM nginx:stable-alpine

LABEL maintainer="Erin Schnabel <schnabel@us.ibm.com> (@ebullientworks)"

RUN apk add --no-cache jq wget tar

ENV ETCD_VERSION 2.2.2

# setup etcd
RUN wget https://github.com/coreos/etcd/releases/download/v${ETCD_VERSION}/etcd-v${ETCD_VERSION}-linux-amd64.tar.gz -q \
  && tar xzf etcd-v${ETCD_VERSION}-linux-amd64.tar.gz etcd-v${ETCD_VERSION}-linux-amd64/etcdctl --strip-components=1 \
  && rm etcd-v${ETCD_VERSION}-linux-amd64.tar.gz \
  && mv etcdctl /usr/local/bin/etcdctl

RUN touch /var/run/nginx.pid && \
  chown -R nginx:nginx /var/run/nginx.pid && \
  chown -R nginx:nginx /var/cache/nginx

COPY nginx.conf        /etc/nginx/nginx.conf
COPY startup.sh        /opt/startup.sh

USER nginx
EXPOSE 8080
EXPOSE 8443

ENTRYPOINT ["/opt/startup.sh"]

HEALTHCHECK \
  --timeout=10s \
  --start-period=40s \
  CMD wget -q -O /dev/null http://localhost:8080/proxy/health
