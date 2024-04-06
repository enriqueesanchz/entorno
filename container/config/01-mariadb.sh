#!/bin/bash

# Strict mode
set -euo pipefail

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

    tar xzf /static.tar.gz ./mariadb
    bzip2 -c -d mariadb/${file} | mysql ${db}
}

clean() {
    service mysql stop

    rm -rf mariadb
}

remove() { :; }

trap clean EXIT

main() {
    configure
    printf "[${package}] Succesfully configured\n"
}

main

