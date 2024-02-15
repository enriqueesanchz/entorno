#!/bin/bash

# Strict mode
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Package name
package="apache2"

# Config
db="sigma"
dbuser="sigma"
dbpass="sigmadb"
file=(
    "cert.key"
    "cert.pem"
    "default-ssl.conf"
    "000-default.conf")

# Aux function
getfromcode()
{
    wget --quiet --user ${dbuser} --password ${dbpass} -N "https://everest.us.es/code/$1" -O "/tmp/$1"
}

# Config

configure() {
    mkdir /tmp/apache2
    getfromcode /apache2/${file[0]}
    getfromcode /apache2/${file[1]}
    mkdir -p /home/sigma
    mv /tmp/apache2/${file[0]} /home/sigma/${file[0]}
    mv /tmp/apache2/${file[1]} /home/sigma/${file[1]}

    a2enmod ssl
    a2enmod proxy
    a2enmod proxy_wstunnel proxy_http proxy_html proxy_ajp
    a2enmod rewrite
    
    printf "${file}"
    getfromcode /apache2/${file[2]}
    getfromcode /apache2/${file[3]}
    mv /tmp/apache2/${file[2]} /etc/apache2/sites-available
    mv /tmp/apache2/${file[3]} /etc/apache2/sites-available
    
    a2ensite default-ssl
    a2ensite 000-default

    service apache2 restart
}

clean() {
    service apache2 stop
    rmdir /tmp/apache2
}

remove() { :; }

trap clean EXIT

main() {
    configure
    printf "[${package}] Succesfully configured"
}

main

