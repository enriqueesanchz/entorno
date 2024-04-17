FROM debian:10-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG db
ARG dbuser
ARG dbpass
ARG wild_user
ARG wild_password
ARG USER
ARG PASSWORD

RUN apt-get -y update && apt-get -y upgrade && \
    echo "wireshark-common wireshark-common/install-setuid boolean true" | \
    debconf-set-selections && \
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
    firefox-esr \
    xfce4 \
    xfce4-terminal \
    gvfs \
    dbus-x11 \
    mariadb-server \
    apache2 \
    tshark \
    sudo && \
    apt-get autoremove && apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 5901

WORKDIR /packages
COPY packages .
RUN chmod +x ./eclipse.sh && ./eclipse.sh && \
    chmod +x ./wildfly.sh && ./wildfly.sh

COPY static /

RUN adduser sigma && adduser sigma sudo && adduser sigma wireshark

WORKDIR /config
COPY config .
RUN for file in $(ls *.sh); do chmod +x ${file} && ./${file}; done

COPY entrypoint.sh /opt/
RUN chmod +x /opt/entrypoint.sh

WORKDIR /home/sigma
CMD ["/opt/entrypoint.sh"]

