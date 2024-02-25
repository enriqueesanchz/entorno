#!/bin/bash

# Strict mode
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Package name
package="war"

# Config
db="sigma"
dbuser="sigma"
dbpass="sigmadb"
file=(
    "sigma.war"
    "SigmaControlWS.war")

# Aux function
getfromcode()
{
    wget --quiet --user ${dbuser} --password ${dbpass} -N "https://everest.us.es/code/$1" -O "/tmp/$1"
}

dodeploy ()
{
    cp /war/${1} /opt/wildfly/standalone/deployments/$(basename ${1})
    touch /opt/wildfly/standalone/deployments/$(basename $1).dodeploy
}

# Config

configure() {
    mkdir /tmp/war
    mkdir /war

    for war in ${file[@]}
    do
        getfromcode /war/${war}
        mv /tmp/war/${war} /war/
        dodeploy ${war}
    done
}

clean() {
    for war in ${file[@]}
    do
        rm /war/${war}
    done
}

remove() { :; }

trap clean EXIT

main() {
    configure
    printf "[${package}] Succesfully configured"
}

main

