#!/bin/bash

# Strict mode
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

# Package name
package="wildfly"

# Config
url='https://downloads.mariadb.com/Connectors/java/connector-java-2.6.2/mariadb-java-client-2.6.2.jar'
INSTALLDIR="/opt"
CLI="$INSTALLDIR/${package}/bin/jboss-cli.sh --connect controller=127.0.0.1"

configure() {
    service mysql restart

    echo JAVA_OPTS=\"-Xms64m -Xmx1024m -XX:+UseG1GC -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=512m -Djava.net.preferIPv4Stack=true -Djboss.modules.system.pkgs=org.jboss.byteman -Djava.awt.headless=true\" >> /opt/wildfly/bin/standalone.conf

    "/opt/${package}/bin/standalone.sh" > /dev/null 2>&1 &
    sleep 5 # TODO: revisar cuando se arranca el proceso
    "/opt/${package}/bin/add-user.sh" -u ${wild_user} -p ${wild_password} -g PowerUser,BillingAdmin, -e

    # Deploy mariadb connector
    wget ${url} -O "/tmp/mariadb-java-client-2.6.2.jar"
    $CLI --commands="deploy /tmp/mariadb-java-client-2.6.2.jar --name=mariadb --runtime-name=mariadb-java-client-2.6.2.jar"
    $CLI --commands="data-source add --jndi-name=java:/sigma/datasource --name=sigmadb --connection-url=jdbc:mysql://127.0.0.1:3306/${db} --driver-class=org.mariad\
b.jdbc.Driver --driver-name=mariadb-java-client-2.6.2.jar --user-name=${dbuser} --password=${dbpass} --statistics-enabled --background-validation --valid-connection-checker-class-n\
ame=org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLValidConnectionChecker --exception-sorter-class-name=org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLExceptionSorter"
    $CLI --command='/system-property=sigma.base:add(value=bar)'
    $CLI --command='/system-property=sigma.base:write-attribute(name="value",value="/etc/sigma")'

    # Configure
    $CLI --command='/socket-binding-group=standard-sockets/socket-binding=http/:write-attribute(name="port",value="${jboss.http.port:49001}")'
    $CLI --command='/subsystem=security:write-attribute(name=initialize-jacc, value=false)'
    
    $CLI -c --commands=":shutdown(restart=true)"
    sleep 10

    $CLI --command='/subsystem=elytron/policy=jacc:add(jacc-policy={})'
    $CLI --command='/subsystem=undertow/application-security-domain=other:add(security-domain=ApplicationDomain,integrated-jaspi=false)'
	$CLI --command='/subsystem=mail/mail-session=default/:write-attribute(name=from, value=notifyS4L@sigma4lifts.com)'
	$CLI --command='/subsystem=mail/mail-session=default/:write-attribute(name=debug, value=true)'
	$CLI --command='/subsystem=mail/mail-session=default/server=smtp/:write-attribute(name=username,value=correomp)'
	$CLI --command='/subsystem=mail/mail-session=default/server=smtp/:write-attribute(name=password,value=mp1234)'
	$CLI --command='/subsystem=mail/mail-session=default/server=smtp/:write-attribute(name=tls,value=false)'
	$CLI --command='/socket-binding-group=standard-sockets/remote-destination-outbound-socket-binding=mail-smtp/:write-attribute(name=host,value=localhost)'
	$CLI --command='/socket-binding-group=standard-sockets/remote-destination-outbound-socket-binding=mail-smtp/:write-attribute(name=port,value=25)'
	#$CLI --command="/subsystem=undertow/servlet-container=default/setting=session-cookie:write-attribute(name=http-only,value=true)"
	#$CLI --command="/subsystem=undertow/servlet-container=default/setting=session-cookie:write-attribute(name=secure,value=true)"
	
	$CLI --command="/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=proxy-address-forwarding,value=true)"
	$CLI --command="/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=require-host-http11,value=true)"
	$CLI --command="/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=redirect-socket,value=https)"
	$CLI --command="/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=secure,value=true)"
}

clean() {
    $CLI -c --commands=":shutdown"
    rm "/tmp/mariadb-java-client-2.6.2.jar"
}

remove() { :; }

trap clean EXIT

main() {
    configure
    printf "[${package}] Succesfully configured\n"
}

main

