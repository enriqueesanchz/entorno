#!/bin/bash

# Strict mode
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Package name
package="apache2"

# Config
configure() {
    mkdir -p /home/sigma
    cp -r /tmp/static/home/sigma/ /home/

    a2enmod ssl
    a2enmod proxy
    a2enmod proxy_wstunnel proxy_http proxy_html proxy_ajp
    a2enmod rewrite
    
    cp -r /tmp/static/apache2/sites-available /etc/apache2

    a2ensite default-ssl
    a2ensite 000-default

    service apache2 restart
}

clean() {
    service apache2 stop
    rm -rf /tmp/static/home/sigma
    rm -rf /tmp/static/apache2

    mkdir -p /default/home/sigma
    mkdir -p /default/etc/apache2
    cp -r /home/sigma /default/home/
    cp -r /etc/apache2 /default/etc/
}

remove() { :; }

trap clean EXIT

main() {
    configure
    printf "[${package}] Succesfully configured\n"
}

main

