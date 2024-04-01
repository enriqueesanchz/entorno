FROM debian:10-slim

RUN apt-get -y update && apt-get -y upgrade

WORKDIR /packages/base
COPY packages/base . 
RUN chmod +x ./wget.sh && ./wget.sh
RUN chmod +x ./git.sh && ./git.sh
RUN chmod +x ./unzip.sh && ./unzip.sh
RUN chmod +x ./bzip2.sh && ./bzip2.sh

WORKDIR /packages/java
COPY packages/java .
RUN chmod +x ./default-jre.sh && ./default-jre.sh
RUN chmod +x ./maven.sh && ./maven.sh

WORKDIR /packages/viewer
COPY packages/viewer .
RUN chmod +x ./x11vnc.sh && ./x11vnc.sh
RUN chmod +x ./xfvb.sh && ./xfvb.sh
EXPOSE 5900

WORKDIR /packages/tools
COPY packages/tools .
RUN chmod +x ./openfortivpn.sh && ./openfortivpn.sh
RUN chmod +x ./eclipse.sh && ./eclipse.sh
RUN chmod +x ./firefox.sh && ./firefox.sh

WORKDIR /packages/server
COPY packages/server .
RUN chmod +x ./apache2.sh && ./apache2.sh
RUN chmod +x ./mariadb-server.sh && ./mariadb-server.sh
RUN chmod +x ./wildfly.sh && ./wildfly.sh

ARG db
ARG dbuser
ARG dbpass
ARG wild_user
ARG wild_password
ARG vpn_user
ARG vpn_password

ENV db $db
ENV dbuser $dbuser
ENV dbpass $dbpass
ENV wild_user $wild_user
ENV wild_password $wild_password
ENV vpn_user $vpn_user
ENV vpn_password $vpn_password

# wildfly in PATH
ENV PATH $PATH:/opt/wildfly/bin/

WORKDIR /config
COPY config .
COPY static.tar.gz /
RUN chmod +x ./mariadb.sh && ./mariadb.sh
RUN chmod +x ./apache2.sh && ./apache2.sh
RUN chmod +x ./wildfly.sh && ./wildfly.sh
RUN chmod +x ./sigma.sh && ./sigma.sh
RUN chmod +x ./openfortivpn.sh && ./openfortivpn.sh

COPY entrypoint.sh /opt/
RUN chmod +x /opt/entrypoint.sh

CMD ["/opt/entrypoint.sh"]

