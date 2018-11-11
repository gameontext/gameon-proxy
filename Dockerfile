FROM nginx:stable-alpine

LABEL maintainer="Erin Schnabel <schnabel@us.ibm.com> (@ebullientworks)"

RUN apk add --no-cache jq

COPY nginx.conf        /etc/nginx/nginx.conf
COPY startup.sh        /opt/startup.sh

EXPOSE 8080

ENTRYPOINT ["/opt/startup.sh"]

HEALTHCHECK \
  --timeout=10s \
  --start-period=40s \
  CMD wget -q -O /dev/null http://localhost/health
