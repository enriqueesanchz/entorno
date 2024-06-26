# Análisis e implementación de un entorno virtualizado de desarrollo y pruebas

Trabajo Final de Máster de Enrique Sánchez Cardoso

- [Problema a resolver](#problema-a-resolver)
- [EaC](#eac)
- [2 alternativas](#2-alternativas)
  - [Alternativa - Contenedor](#alternativa---contenedor)
  - [Alternativa - Máquina virtual](#alternativa---máquina-vitual)
- [Contenedor](#contenedor)
  - [Dependencias](#dependencias)
  - [Build](#build)
  - [Uso](#uso)
  - [Despliegue en la nube](#despliegue-en-la-nube)
    - [AWS](#aws)
  - [Componentes](#componentes)
    - [Dockerfile](#dockerfile)
    - [compose.yaml](#composeyaml)
    - [Scripts de instalación](#scripts-de-instalación)
    - [Scripts de configuración](#scripts-de-configuración)
    - [Ficheros estáticos](#ficheros-estáticos)
  - [Volúmenes](#volúmenes)
  - [Caché de docker](#caché-de-docker)

- [Máquina virtual](#máquina-virtual)
  - [Dependencias](#dependencias-1)
  - [Uso](#uso-1)
  - [Despliegue en la nube](#despliegue-en-la-nube-1)
    - [AWS](#aws-1)
  - [Desventajas](#desventajas)
    - [Rapidez de iteración](#rapidez-de-iteración)
    - [Levantar, destruir y crear](#levantar-destruir-y-crear)
    - [Deriva](#deriva)
    - [Almacenamiento](#almacenamiento)
    - [NFS](#nfs)

## Problema a resolver

Parte de los problemas que surgen en un equipo de desarrollo que trabaja sobre un mismo stack (BBDD, servidor de aplicaciones, datos de prueba, etc.) se deben a las diferencias en la configuración de la arquitectura que están usando, los datos de prueba, deficiencia en la gestión de dependencias, "it works on my machine", etc.

## EaC

Con este trabajo se propone un entorno de desarrollo definido mediante código (EaC). Esto permite llevar un control de versiones de dicho código, y en consecuencia, del entorno.

## 2 alternativas

### Alternativa - Contenedor

Esta es la opción escogida. Permite crear contenedores efímeros que contengan la arquitectura completa necesaria para trabajar. Cuando queramos modificar esta arquitectura lo haremos mediante el Dockerfile y los scripts de instalación/configuración. Estos estarán versionados.

### Alternativa - Máquina vitual

En un principio se exploró esta opción ya que permite montar un entorno automatizado mediante Vagrant y scripts de configuración. Se terminó descartando puesto que una vez sea construida la máquina no se puede llevar un control de los cambios sobre ella, entrando de nuevo en la deriva del entorno de desarrollo. No ofrece mejoras respecto al entorno en contenedores.

## Contenedor

### Dependencias

Debemos tener instalado en la máquina host:

- Docker
- Tiger VNC viewer

### Build

- ARGS
  - db: nombre de la base de datos
  - dbuser: usuario de la base de datos
  - dbpass: contraseña de la base de datos
  - wild_user: usuario administrador de wildfly
  - wild_password: contraseña de administrador de wildfly

Si queremos hacer un build en local nos dirijimos al directorio `container` y ejecutamos:

```bash
docker build -t enriqueesanchz/entorno \
--build-arg db=sigma \
--build-arg dbuser=sigma \
--build-arg dbpass=sigmadb \
--build-arg wild_user=admin \
--build-arg wild_password=admin .
```

Al hacer un push a github, si hemos modificado el build context, se lanza un pipeline para la construcción de la imagen y su publicación en dockerhub.

### Uso

Si solo queremos ser usuarios de este entorno podemos usar la versión de la imagen de dockerhub:

```yaml
services:
  desarrollo:
    image: enriqueesanchz/entorno:latest
    environment:
      - vpn_user=${vpn_user}
      - vpn_password=${vpn_password}
      - tigervncpasswd=${tigervncpasswd}
    ports: 
      - "6901:5901" # vnc server
    volumes:
      - ./volumes/opt/wildfly/standalone:/opt/wildfly/standalone
      - ./volumes/etc/apache2:/etc/apache2
      - ./volumes/home/sigma:/home/sigma
      - ./volumes/var/lib/mysql:/var/lib/mysql
      - ./volumes/etc/openfortivpn:/etc/openfortivpn
      - ./volumes/code:/code
    devices:
      - /dev/ppp:/dev/ppp
    cap_add:
      - "NET_ADMIN"
      - "NET_RAW"
```

1. Establecer las variables de entorno `vpn_user`, `vpn_password` y `tigervncpasswd`
   - vpn_user: usuario para la vpn de openfortivpn
   - vpn_password: contraseña para el usuario de la vpn de openfortivpn
   - tigervncpasswd: contraseña para acceder mediante vnc
2. `docker compose up`
3. Instalar en la máquina host TigerVNC viewer
4. `vncviewer localhost:6901`

### Despliegue en la nube

#### AWS

Usando terraform se puede desplegar el entorno creado mediante contenedor de manera automática, en este caso, en AWS Elastic Beanstalk. Para ello debemos:

- Crear un rol con permisos para crear y destruir instancias EC2 y sus respectivos grupos de seguridad, y buckets S3.
- Rellenar el fichero terraform.tfvars con los nombres que queramos establecer
- Crear el fichero secrets.tf y añadir las variables `vpn_user`, `vpn_password` y `tigervncpasswd` (sensitive para terraform)
- Ejecutar `terraform init` y `terraform apply`

El fichero main.tf está configurado para hacer uso de la capa gratuita de EC2 y S3. Primero sube el compose.yaml a S3, el cual usará Beanstalk para desplegar el contenedor en unas instancia EC2 con Docker.

Tendremos un security group que permita el tráfico al puerto 6901 con el que podremos acceder mediante VNC.

Al final de la ejecución terraform nos muestra el dns al que acceder usando VNC.

```bash
Outputs:
public_dns = "entorno-env.eba-wyvpg3dn.eu-west-3.elasticbeanstalk.com"
```

## Componentes

### Dockerfile

Se encarga de agrupar los pasos necesarios para la construcción de la imagen que usaremos de entorno de desarrollo. Consta de 5 secciones:

1. Inicio: declara la imagen de partida (si existe)
2. Argumentos: establece variables de entorno, entre otros, para la gestión de secretos, durante el tiempo de build
3. Instalación de paquetes: ejecuta la instalación mediante gestor de paquetes y scripts organizados en la carpeta ./packages 
4. Configuración: ejecuta los scripts localizados en ./config
5. Entrypoint: establece el script que se ejecuta cuando se lance el contenedor

### compose.yaml

Permite declarar:

1. El reenvío de puertos a la máquina host
2. Los volúmenes a compartir entre host y contenedor
3. Las variables de entorno

### Scripts de instalación

Los scripts de instalación se localizan en el directorio ./packages, organizados según el tipo de paquete que instalan.

Se han seguido las siguientes buenas prácticas:

- set -e: finaliza inmediatamente el script si algún comando devuelve un estado diferente de 0. Esto nos permite detectar más rápido los errores.
- set -u: finaliza inmediatamente el script si alguna variable se usa y no ha sido previamente definida.
- set -o pipefail: previene el enmascaramiento de errores en los pipelines (por defecto, el resultado de un pipeline es el del último comando).
- trap: Antes de finalizar se ejecuta la función clean (trap EXIT).
- Plantilla: forma estandarizada de declarar cómo se instala un paquete, cómo limpiar los pasos intermedios, y como desinstalarlo. 

```bash
#!/bin/bash

# Strict mode
set -euo pipefail

# Package name
package="<nombre del paquete>"

install() {
    #<instrucciones de instalacion del paquete>
}

clean() {
    #<instrucciones para limpiar pasos intermedios>
}

remove() {
    #<instrucciones para desinstalar el paquete>
}

trap clean EXIT

main() {
    install
    printf "[<metodo>] Succesfully installed ${package}\n"
}

main

```

Consideraciones:

- Se ha preferido la instalación mediante gestores de paquetes frente a binarios cuando ha sido posible.
- Se ha usado apt-get frente a apt debido a que su sintaxis es más estable (se recomienda para scripts).

### Scripts de configuración

Siguen las mismas buenas prácticas que los scripts de instalación pero se encargan de configurar.

### Ficheros estáticos

Los ficheros estáticos se encuentran en la carpeta ./static. Son ficheros de configuración cuya ruta parte de la carpeta static como si esta fuera la raíz del sistema. También incluye claves ssh que no nos importa versionar puesto que son de prueba para el entorno de desarrollo.

## Volúmenes

Los volúmenes se han utilizado para compartir ficheros entre la máquina host y el contenedor de desarrollo, así como para persistir la información que queramos tener en sucesivas ejecuciones:

- Código que estamos desarrollando
- Base de datos
- Directorio de usuario
- Configuraciones
  - Wildfly
  - Apache
  - VPN

## Caché de docker

Cada instrucción RUN y COPY generan una capa nueva para la imagen. Estas se ordenan según aparecen en el Dockerfile. Si no modificamos una capa ni las anteriores, en el próximo build se reutilizarán, acelerando la construcción de la imagen. Por ello:

1. Ordenamos las capas del Dockerfile colocando primero las que menos vayamos a modificar. Esto nos permitirá invalidar menos veces la caché.
2. Tendremos más o menos capas según reconozcamos la necesidad de iterar rápido en la construcción del entorno, o de optimizar el peso de la imagen.

---

## Máquina virtual

Se ha incluido para justificar la comparación con la solución de contenedores, pero vistas las razones anteriormente expuestas, no presenta ventajas.

### Dependencias

Debemos tener instalado en la máquina host:

- Virtualbox
- Vagrant + plugin vagrant-vbguest
- Servidor NFS
- Tiger VNC viewer

### Uso

1. Establecer las variables de entorno `vpn_user` y `vpn_password`
2. Rellenar las variables de build en el fichero `provision.sh`
3. En el directorio `vm` ejecutamos `vagrant up`. La primera vez se ejecutará el script de provisioning que construye el entorno.
4. Instalar en la máquina host TigerVNC viewer
5. `vncviewer localhost:6901`

### Despliegue en la nube

#### AWS

Usando terraform se puede desplegar el entorno creado mediante máquina virtual de manera automática, en este caso, en AWS EC2. Para ello debemos:

- Rellenar el fichero terraform.tfvars con los nombres que queramos establecer
- Editar las variables de build establecidas en el script provision.sh que se ejecutará para crear el entonrno
- Crear el fichero secrets.tf y añadir las variables `tigervncpasswd` (sensitive para terraform)
- Ejecutar `terraform init` y `terraform apply`

El fichero main.tf está configurado para hacer uso de la capa gratuita de EC2. Tendremos un security group que permita el tráfico al puerto 5901 con el que podremos acceder mediante VNC.

Al final de la ejecución terraform nos muestra el dns al que acceder usando VNC.

```bash
Outputs:
public_dns = "ec2-35-180-36-38.eu-west-3.compute.amazonaws.com"
```

### Desventajas

#### Rapidez de iteración

A diferencia de los contenedores, las máquinas virtuales no utilizan el modelo por capas, por lo que modificar algo en los scripts de provisionamiento (necesario mantenerlos actualizados si queremos que todos los entornos sean iguales) conlleva la destrucción y creación de nuevo de la máquina virtual. Esto es un proceso lento y tedioso.

#### Levantar, destruir y crear

Lo ideal es tener un entorno "como nuevo" cada vez. De nuevo, destruir y crear una máquina virtual es más lento que un contenedor, incluso levantarla es más lento que crear un nuevo contenedor.

#### Deriva

Una vez construida la máquina virtual no se puede llevar un control de cambios sobre ella.

#### Almacenamiento

Podemos seleccionar un disco virtual dinámico para optimizar el espacio que ocupa en el host. Sin embargo, este disco solo crecerá (nunca decrece). A pesar de que liberemos espacio, con cada creación de un archivo, crece.

Ejemplo:

```console
# En el host
enrique@desktop:/cloud# du -ha debian-10.13-amd64-disk001.vmdk
1,5G    debian-10.13-amd64-disk001.vmdk

# Creamos un archivo de 1 GB en la máquina guest
root@cloud:/# tail --bytes 1G /dev/random > 1_gb

# En el host
enrique@desktop:/cloud# du -ha debian-10.13-amd64-disk001.vmdk
2,5G    debian-10.13-amd64-disk001.vmdk

# Eliminamos el archivo anterior de la máquina guest
root@cloud:/# rm 1_gb

# En el host
enrique@desktop:/cloud# du -ha debian-10.13-amd64-disk001.vmdk
2,5G    debian-10.13-amd64-disk001.vmdk

# Creamos otro archivo de 1 GB en la máquina guest
root@cloud:/# tail --bytes 1G /dev/random > otro_gb

# En el host
enrique@desktop:/cloud# du -ha debian-10.13-amd64-disk001.vmdk
3,4G    debian-10.13-amd64-disk001.vmdk
```

Realmente cuando borramos el fichero no se borra sino que se marca como que no está, pero sigue en el disco, ubicado en nuestra máquina host. Esto hace que el fichero no ocupe espacio en la máquina guest pero si en la host.

Podemos verlo como una desventaja puesto que ocupa un espacio que en el caso de usar contenedor no ocuparía.

#### NFS

Para poder compartir el directorio de datos de mariadb (/var/lib/mysql) se ha necesitado hacer uso de NFS ya que no es compatible con el método estándar de carpetas sincronizadas de Virtualbox.
