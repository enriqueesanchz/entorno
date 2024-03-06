#!/bin/bash

# Strict mode
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Package name
package="war"

dodeploy ()
{
    cp /war/${1} /opt/wildfly/standalone/deployments/$(basename ${1})
    touch /opt/wildfly/standalone/deployments/$(basename $1).dodeploy
}

# Config

configure() {
    mkdir /war

    for war in $(ls /tmp/default/war)
    do
        mv /tmp/default/war/${war} /war/
        dodeploy ${war}
    done
}

clean() {
    for war in $(ls /tmp/default/war)
    do
        rm /war/${war}
    done
}

remove() { :; }

trap clean EXIT

main() {
    configure
    printf "[${package}] Succesfully configured\n"
}

main

