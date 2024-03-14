#!/bin/bash

# Strict mode
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Package name
package="mariadb-server"

# Config
file="${db}_desarrollo.sql.bzip2"

configure() {
    service mysql restart

    cat <<EOF | mysql                                                         
CREATE DATABASE ${db};                                                                    
CREATE USER '${dbuser}'@'localhost' IDENTIFIED BY '${dbpass}';                                
GRANT ALL PRIVILEGES ON ${db}.* TO '${dbuser}'@'localhost';                                   
EOF

    bzip2 -c -d /tmp/static/mariadb/${file} | mysql ${db}
}

clean() {
    service mysql stop
    rm -rf /tmp/static/mariadb

    mkdir -p /default/var/lib/mysql
    cp -r /var/lib/mysql /default/var/lib/
    chown -R mysql:mysql /default/var/lib/mysql
}

remove() { :; }

trap clean EXIT

main() {
    configure
    printf "[${package}] Succesfully configured\n"
}

main

