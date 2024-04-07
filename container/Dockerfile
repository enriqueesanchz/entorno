FROM debian:10-slim
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get -y update && apt-get -y upgrade && \
    apt-get install -y --no-install-recommends \
    wget \
    git \
    unzip \
    bzip2 \
    default-jre \
    maven \
    tigervnc-standalone-server \
    tigervnc-common \
    openfortivpn \
    firefox-esr && \
    apt-get autoremove && apt-get clean

RUN apt-get install -y xfce4 && \
    apt-get autoremove && apt-get clean

EXPOSE 5901

WORKDIR /packages
COPY packages .
RUN chmod +x ./eclipse.sh && ./eclipse.sh
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
ARG USER
ARG PASSWORD

ENV db $db
ENV dbuser $dbuser
ENV dbpass $dbpass
ENV wild_user $wild_user
ENV wild_password $wild_password
ENV vpn_user $vpn_user
ENV vpn_password $vpn_password
ENV USER $USER
ENV PASSWORD $PASSWORD

COPY static /

WORKDIR /config
COPY config .
RUN for file in $(ls *.sh); do chmod +x ${file} && ./${file}; done

COPY entrypoint.sh /opt/
RUN chmod +x /opt/entrypoint.sh

WORKDIR /root
CMD ["/opt/entrypoint.sh"]

