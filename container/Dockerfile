FROM debian:10-slim

RUN apt -y update && apt -y upgrade

WORKDIR /packages/base
COPY packages/base . 
RUN chmod +x ./curl.sh && ./curl.sh
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

WORKDIR /packages/server
COPY packages/server .
RUN chmod +x ./apache2.sh && ./apache2.sh
RUN chmod +x ./mariadb-server.sh && ./mariadb-server.sh
RUN chmod +x ./wildfly.sh && ./wildfly.sh

WORKDIR /config
COPY config .
COPY RelayMap.txt /home/sigma/
RUN chmod +x ./mariadb.sh && ./mariadb.sh
RUN chmod +x ./apache2.sh && ./apache2.sh
RUN chmod +x ./wildfly.sh && ./wildfly.sh
RUN chmod +x ./sigma.sh && ./sigma.sh
RUN chmod +x ./wars.sh && ./wars.sh

CMD ["bash"]

