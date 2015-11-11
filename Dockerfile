FROM ubuntu:trusty

MAINTAINER Ben Smith (benjsmi@us.ibm.com)

ADD https://download.elastic.co/logstash-forwarder/binaries/logstash-forwarder_linux_amd64 /opt/forwarder
ADD http://game-on.org:8081/logstashneeds.tar /opt/logstashneeds.tar

RUN cd /opt ; echo deb http://archive.ubuntu.com/ubuntu trusty-backports main universe | \
    tee /etc/apt/sources.list.d/backports.list ; apt-get update ; apt-get install -y haproxy -t trusty-backports ; \
    mkdir -p /run/haproxy/ ; apt-get install -y rsyslog ; cd /opt ; chmod +x ./forwarder ; \
    tar xvzf logstashneeds.tar ; rm logstashneeds.tar

COPY ./rsyslog.conf /etc/rsyslog.conf
COPY ./49-haproxy.conf /etc/rsyslog.d/49-haproxy.conf
COPY ./50-default.conf /etc/rsyslog.d/50-haproxy.conf
COPY ./proxy.pem /etc/ssl/proxy.pem
COPY ./startup.sh /opt/startup.sh
COPY ./forwarder.conf /opt/forwarder.conf

COPY ./haproxy.cfg /etc/haproxy/haproxy.cfg

EXPOSE 80 443 1936

CMD ["/opt/startup.sh"]
