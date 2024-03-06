#!/bin/bash

# Strict mode
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Package name
package="mariadb-server"

# Config
db="sigma"
dbuser="sigma"
dbpass="sigmadb"
file="${db}_desarrollo.sql.bzip2"

configure() {
    service mysql restart

    cat <<EOF | mysql                                                         
CREATE DATABASE ${db};                                                                    
CREATE USER '${dbuser}'@'localhost' IDENTIFIED BY '${dbpass}';                                
GRANT ALL PRIVILEGES ON ${db}.* TO '${dbuser}'@'localhost';                                   
EOF

    bzip2 -c -d /tmp/default/mariadb/${file} | mysql ${db}
}

clean() {
    service mysql stop
}

remove() { :; }

trap clean EXIT

main() {
    configure
    printf "[${package}] Succesfully configured"
}

main

