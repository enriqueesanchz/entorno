#!/bin/bash
DB=sigma
DBUSER=sigma
DBPASS=sigmadb
WILDFLY=wildfly#23.0.2.Final
GV=4.2.8.Final
USER=sigma
INSTALLDIR=/opt
export LC_ALL="C"

export CLI="$INSTALLDIR/wildfly/bin/jboss-cli.sh --connect controller=127.0.0.1"


getfromcode()
{
    wget --quiet --user $DBUSER --password $DBPASS -N https://everest.us.es/code/$1
}

sistemabase ()
{
    OPTIONS='-y -q  -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold"'
    APTGET='sudo DEBIAN_FRONTEND=noninteractive apt-get '
    
    $APTGET $OPTIONS install grub-pc
    $APTGET $OPTIONS dist-upgrade
    $APTGET $OPTIONS update
    apt-get -y install default-jre curl unzip mariadb-server
}

dodeploy ()
{
    echo ####### Deploying $1
    cp $1 /opt/wildfly/standalone/deployments/`basename $1`
    touch /opt/wildfly/standalone/deployments/`basename $1`.dodeploy
}


limpiar ()
{
    echo ####### Removing: wildfly, apache2, galleon, mariadb
    echo Ejecutar a mano
    exit 1
    systemctl stop wildfly
    systemctl stop apache2
    rm -rf /opt/galleon*
    rm -rf /opt/wildfly
    rm -rf /etc/apache2
    systemctl disable wildfly
    systemctl daemon-reload
    rm /etc/systemd/system/wildfly.service
cat <<EOF | mysql
DROP DATABASE $DB;
DROP USER 'sigma'@'localhost';
EOF
    apt purge -y mariadb-server
    apt purge -y apache2
    sleep 10
}


installwildflyandconnector ()
{
if [ "x$JAVA_HOME" = "x" ]; then
   echo JAVA_HOME undefined
   exit 1
fi
    echo ####### Install galleon, wildfly, configure them
    cd /tmp
    curl -s -L -O --insecure https://github.com/wildfly/galleon/releases/download/$GV/galleon-$GV.zip
    unzip galleon-$GV.zip -d /opt
    ln -s /opt/galleon-$GV /opt/galleon
    /opt/galleon/bin/galleon.sh install $WILDFLY --dir=/opt/wildfly
    groupadd -r wildfly
    useradd -r -g wildfly -d /opt/wildfly -s /sbin/nologin wildfly
    chown -RH wildfly: /opt/wildfly
    mkdir -p /etc/wildfly
    cp /opt/wildfly/docs/contrib/scripts/systemd/wildfly.conf /etc/wildfly/
    cp /opt/wildfly/docs/contrib/scripts/systemd/launch.sh    /opt/wildfly/bin/
    chmod +x /opt/wildfly/bin/*.sh
    cp /opt/wildfly/docs/contrib/scripts/systemd/wildfly.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable wildfly
    systemctl start  wildfly
    sleep 5
    /opt/wildfly/bin/add-user.sh -u admin -p admin -g PowerUser,BillingAdmin, -e

    # We deploy mariadb connector                                                       
    cd /tmp
    curl -s -o mariadb-java-client-2.6.2.jar --insecure https://downloads.mariadb.com/Connectors/java/connector-java-2.6.2/mariadb-java-client-2.6.2.jar
    $CLI --commands="deploy /tmp/mariadb-java-client-2.6.2.jar --name=mariadb --runtime-name=mariadb-java-client-2.6.2.jar"
    $CLI --commands="data-source add --jndi-name=java:/sigma/datasource --name=sigmadb --connection-url=jdbc:mysql://127.0.0.1:3306/$DB --driver-class=org.mariad\
b.jdbc.Driver --driver-name=mariadb-java-client-2.6.2.jar --user-name=$DBUSER --password=$DBPASS --statistics-enabled --background-validation --valid-connection-checker-class-n\
ame=org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLValidConnectionChecker --exception-sorter-class-name=org.jboss.jca.adapters.jdbc.extensions.mysql.MySQLExceptionSorter"
    $CLI --command='/system-property=sigma.base:add(value=bar)'
    $CLI --command='/system-property=sigma.base:write-attribute(name="value",value="/etc/sigma")'
}

configurewildfly () {
    # Configure wildfly                                                                 
    $CLI --command='/socket-binding-group=standard-sockets/socket-binding=http/:write-attribute(name="port",value="${jboss.http.port:49001}")'
    $CLI --command='/subsystem=security:write-attribute(name=initialize-jacc, value=false)'
    systemctl stop wildfly;systemctl start wildfly;sleep 10
    $CLI --command='/subsystem=elytron/policy=jacc:add(jacc-policy={})'
    $CLI --command='/subsystem=undertow/application-security-domain=other:add(security-domain=ApplicationDomain,integrated-jaspi=false)'
	$CLI --command='/subsystem=mail/mail-session=default/:write-attribute(name=from, value=notifyS4L@sigma4lifts.com)'
	$CLI --command='/subsystem=mail/mail-session=default/:write-attribute(name=debug, value=true)'
#	$CLI --command='/subsystem=mail/mail-session=default/:write-attribute(name=activo, value=true)'
	$CLI --command='/subsystem=mail/mail-session=default/server=smtp/:write-attribute(name=username,value=correomp)'
	$CLI --command='/subsystem=mail/mail-session=default/server=smtp/:write-attribute(name=password,value=mp1234)'
	$CLI --command='/subsystem=mail/mail-session=default/server=smtp/:write-attribute(name=tls,value=false)'
	$CLI --command='/socket-binding-group=standard-sockets/remote-destination-outbound-socket-binding=mail-smtp/:write-attribute(name=host,value=localhost)'
	$CLI --command='/socket-binding-group=standard-sockets/remote-destination-outbound-socket-binding=mail-smtp/:write-attribute(name=port,value=25)'
	$CLI --command="/subsystem=undertow/servlet-container=default/setting=session-cookie:write-attribute(name=http-only,value=true)"
	$CLI --command="/subsystem=undertow/servlet-container=default/setting=session-cookie:write-attribute(name=secure,value=true)"
	
	$CLI --command="/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=proxy-address-forwarding,value=true)"
	$CLI --command="/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=require-host-http11,value=true)"
	$CLI --command="/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=redirect-socket,value=https)"
	$CLI --command="/subsystem=undertow/server=default-server/http-listener=default:write-attribute(name=secure,value=true)"
	
    systemctl stop wildfly;systemctl start wildfly;sleep 10
}

increasewildflymemory () 
{
	echo JAVA_OPTS=\"-Xms64m -Xmx1024m -XX:+UseG1GC -XX:MetaspaceSize=96M -XX:MaxMetaspaceSize=512m -Djava.net.preferIPv4Stack=true -Djboss.modules.system.pkgs=org.jboss.byteman -Djava.awt.headless=true\" >> /opt/wildfly/bin/standalone.conf
    systemctl stop wildfly;systemctl start wildfly;sleep 10
}


installdb ()
{
    MYSQL=`which mysql`
	if [ "x$MYSQL" = "x" ] 
    then 
		echo ####### Install mariadb
		apt-get install -y mariadb-server
		cd /tmp
		systemctl enable mariadb
   fi
	echo "Comprobando si la DB esta configurada"
	DBINSTALLED=`echo show tables\;|mysql --user=$DBUSER --password=$DBPASS $DB|wc -l`
	if [ $DBINSTALLED = "0" ]
	then
		echo "Configurando la DB"
		cat <<EOF | mysql                                                         
CREATE DATABASE $DB;                                                                    
CREATE USER '$DBUSER'@'localhost' IDENTIFIED BY '$DBPASS';                                
GRANT ALL PRIVILEGES ON $DB.* TO '$DBUSER'@'localhost';                                   
EOF
		getfromcode $DB\_desarrollo.sql.bzip2
		bzip2 -c -d $DB\_desarrollo.sql.bzip2 | mysql $DB
	else
		echo $DB installed, do not delete
    fi
}


sigmaconf ()
{
    cd /tmp
    getfromcode sigmatree.tgz
    cd /
    tar zxf /tmp/sigmatree.tgz
    rm /tmp/sigmatree.tgz
}

installapache ()
{
    echo ####### Install apache
    apt install -y apache2
   
    mkdir -p /home/sigma
    cd /home/sigma
    getfromcode apache2/cert.key
    getfromcode apache2/cert.pem

    a2enmod   ssl
    a2enmod   proxy
    a2enmod   proxy_wstunnel proxy_http proxy_html proxy_ajp
    a2enmod   rewrite

    cd /etc/apache2/sites-available
    getfromcode apache2/default-ssl.conf
    getfromcode apache2/000-default.conf
    a2ensite  default-ssl
    a2ensite  000-default

    systemctl restart apache2
}

deploywars ()
{
    systemctl start wildfly

    for war in sigma.war SigmaControlWS.war
    do
	getfromcode war/$war
	dodeploy $war
    done
}

main () 
{
echo "Commands"
cat <<EOF
limpiar
installwildflyandconnector
configurewildfly
increasewildflymemory
installdb
sigmaconf
installapache
deploywars
EOF
}

fromzero()
{
JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/bin/java
sistemabase
installwildflyandconnector
configurewildfly
increasewildflymemory
installdb
sigmaconf
installapache
deploywars
}

fromzero
fromzero()
