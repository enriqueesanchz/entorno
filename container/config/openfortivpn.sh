#!/bin/bash

# Strict mode
set -euo pipefail

# Package name
package="openfortivpn"

# Config
configure() {

cat > /tmp/miconf <<EOF
# config file for openfortivpn, see man openfortivpn(1)
host=95.60.241.174
port=10445
username=${vpn_user}
password=${vpn_password}
trusted-cert=2341484be0f5a5dd30335297badbfc6fcd3195f33e7286e1e5b71cd50d5035cc
EOF

    cp /tmp/miconf /etc/openfortivpn/config
}

clean() {
    rm /tmp/miconf
    mkdir -p /default/etc/openfortivpn
    cp /etc/openfortivpn/config /default/etc/openfortivpn
}

remove() { :; }

trap clean EXIT

main() {
    configure
    printf "[${package}] Succesfully configured\n"
}

main

