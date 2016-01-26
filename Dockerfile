FROM ubuntu:trusty
MAINTAINER Chad Schmutzer <schmutze@amazon.com>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get -q update && \
  apt-get -y -q dist-upgrade && \
  apt-get -y -q install rsyslog python-setuptools python-pip curl

RUN curl https://s3.amazonaws.com/aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -o awslogs-agent-setup.py

RUN sed -i "s/#\$ModLoad imudp/\$ModLoad imudp/" /etc/rsyslog.conf && \
  sed -i "s/#\$UDPServerRun 514/\$UDPServerRun 514/" /etc/rsyslog.conf && \
  sed -i "s/#\$ModLoad imtcp/\$ModLoad imtcp/" /etc/rsyslog.conf && \
  sed -i "s/#\$InputTCPServerRun 514/\$InputTCPServerRun 514/" /etc/rsyslog.conf

RUN sed -i "s/authpriv.none/authpriv.none,local6.none,local7.none/" /etc/rsyslog.d/50-default.conf

RUN echo '$template api,"%msg%\\n"' >> /etc/rsyslog.d/site.conf && \
  echo "if \$syslogfacility-text == 'local6' and \$programname == 'api' then /var/log/api.log;api" >> /etc/rsyslog.d/site.conf && \
  echo "if \$syslogfacility-text == 'local6' and \$programname == 'api' then stop" >> /etc/rsyslog.d/site.conf && \
  echo "if \$syslogfacility-text == 'local6' and \$programname == 'letsencrypt' then /var/log/letsencrypt.log" >> /etc/rsyslog.d/site.conf && \
  echo "if \$syslogfacility-text == 'local6' and \$programname == 'letsencrypt' then stop" >> /etc/rsyslog.d/site.conf && \
  echo "if \$syslogfacility-text == 'local6' and \$programname == 'nginx' then /var/log/nginx-access.log" >> /etc/rsyslog.d/site.conf && \
  echo "if \$syslogfacility-text == 'local6' and \$programname == 'nginx' then stop" >> /etc/rsyslog.d/site.conf && \
  echo "if \$syslogfacility-text == 'local7' and \$programname == 'nginx' then /var/log/nginx-error.log" >> /etc/rsyslog.d/site.conf && \
  echo "if \$syslogfacility-text == 'local7' and \$programname == 'nginx' then stop" >> /etc/rsyslog.d/site.conf

COPY awslogs.conf awslogs.conf
COPY run.sh run.sh

RUN pip install supervisor
COPY supervisord.conf /usr/local/etc/supervisord.conf

EXPOSE 514/tcp 514/udp
CMD ["/run.sh"]
