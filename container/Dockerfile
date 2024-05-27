FROM alpine:3.20 as eclipse-builder

RUN apk add bash wget

WORKDIR /packages
COPY ./packages/eclipse.sh .
RUN chmod +x ./eclipse.sh && ./eclipse.sh

FROM alpine:3.20 as wildfly-builder

RUN apk add bash wget unzip openjdk11

WORKDIR /packages
COPY ./packages/wildfly.sh .
RUN chmod +x ./wildfly.sh && ./wildfly.sh

FROM debian:10-slim

ARG DEBIAN_FRONTEND=noninteractive

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

COPY --from=wildfly-builder --chown=sigma:sigma /opt/wildfly /opt/wildfly
COPY --from=eclipse-builder --chown=sigma:sigma /opt/eclipse /opt/eclipse

COPY static /

RUN adduser sigma && adduser sigma sudo && adduser sigma wireshark

WORKDIR /config
COPY config .
ARG db
ARG dbuser
ARG dbpass
ARG wild_user
ARG wild_password
ARG tigervncpasswd
RUN for file in *.sh; do chmod +x ${file} && ./${file}; done

COPY entrypoint.sh /opt/
RUN chmod +x /opt/entrypoint.sh

WORKDIR /home/sigma
CMD ["/opt/entrypoint.sh"]

