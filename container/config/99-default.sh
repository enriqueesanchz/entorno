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

    chown -R sigma:sigma /home/sigma
    mkdir -p /default/home
    mv /home/sigma /default/home
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

