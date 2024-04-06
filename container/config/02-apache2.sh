#!/bin/bash

# Strict mode
set -euo pipefail

# Package name
package="apache2"

# Config
configure() {
    mkdir -p /home/sigma
    tar xzf /static.tar.gz -C / ./home

    a2enmod ssl
    a2enmod proxy
    a2enmod proxy_wstunnel proxy_http proxy_html proxy_ajp
    a2enmod rewrite
    
    tar xzf /static.tar.gz -C / ./etc/apache2

    a2ensite default-ssl
    a2ensite 000-default

    service apache2 restart
}

clean() {
    service apache2 stop
}

remove() { :; }

trap clean EXIT

main() {
    configure
    printf "[${package}] Succesfully configured\n"
}

main

