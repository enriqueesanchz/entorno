#!/bin/bash

# Strict mode
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Package name
package="sigma"

# Config
db="sigma"
dbuser="sigma"
dbpass="sigmadb"
file="sigmatree.tgz"

# Aux function
getfromcode()
{
    wget --quiet --user ${dbuser} --password ${dbpass} -N "https://everest.us.es/code/$1" -O "/tmp/$1"
}

# Config

configure() {
    getfromcode ${file}
    tar zxf /tmp/sigmatree.tgz -C /
    cp /vagrant/RelayMap.txt /home/sigma/
}

clean() {
    rm /tmp/${file}
}

remove() { :; }

trap clean EXIT

main() {
    configure
    printf "[${package}] Succesfully configured"
}

main

