#!/bin/bash

# Strict mode
set -euo pipefail

# Package name
package="default"

# Config
configure() {
    mkdir -p /default/var/lib/mysql
    mv /var/lib/mysql /default/var/lib

    mkdir -p /default/etc
    mv /etc/apache2 /default/etc
    
    mkdir -p /default/opt/wildfly
    mv /opt/wildfly/standalone /default/opt/wildfly

    mv /etc/openfortivpn /default/etc/openfortivpn

    mkdir -p /default/home
    mv /home/sigma /default/home

    mkdir /default/root
    mv /root/.vnc /default/root
}

clean() { 
    :
}

remove() { :; }

trap clean EXIT

main() {
    configure
    printf "[${package}] Succesfully configured\n"
}

main

