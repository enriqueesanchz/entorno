# Análisis e implementación de un entorno virtualizado de desarrollo y pruebas

Trabajo Final de Máster de Enrique Sánchez Cardoso

## Problema a resolver

Parte de los problemas que surgen en un equipo de desarrollo que trabaja sobre un mismo stack (BBDD, servidor de aplicaciones, datos de prueba, etc.) se deben a las diferencias en la configuración de la arquitectura que están usando, los datos de prueba, deficiencia en la gestión de dependencias, "it works on my machine", etc.

## EaC

Con este trabajo se propone un entorno de desarrollo definido mediante código (EaC). Esto permite llevar un control de versiones de dicho código, y en consecuencia, del entorno.

## 2 alternativas

### Máquina vitual

En un principio se exploró esta opción ya que permite montar un entorno automatizado mediante Vagrant y scripts de configuración. Se terminó descartando puesto que una vez sea construida la máquina no se puede llevar un control de los cambios sobre ella, entrando de nuevo en la deriva del entorno de desarrollo.

### Contenedor

Esta es la opción escogida. Permite crear contenedores efímeros que contengan la arquitectura completa necesaria para trabajar. Cuando queramos modificar esta arquitectura lo haremos mediante el Dockerfile y los scripts de instalación/configuración. Estos estarán versionados.

## Componentes

### Dockerfile

Se encarga de agrupar los pasos necesarios para la construcción de la imagen que usaremos de entorno de desarrollo. Consta de 5 secciones:

1. Inicio: declara la imagen de partida (si existe)
2. Instalación de paquetes: ejecuta los scripts organizados en carpetas en ./packages 
3. Variables de entorno: establece variables de entorno, entre otros, para la gestión de secretos
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

export DEBIAN_FRONTEND=noninteractive

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

Los ficheros estáticos se encuentran en la carpeta ./static, la cual no está subida al repositorio Git debido a que el control de versiones tradicional no está hecho para subir archivos de gran tamaño.

- Plantear sistema de versiones mendiante hash para garantizar consistencia

## Caché de docker

Cada instrucción RUN y COPY generan una capa nueva para la imagen. Estas se ordenan según aparecen en el Dockerfile. Si no modificamos una capa ni las anteriores, en el próximo build se reutilizarán, acelerando la construcción de la imagen. Por ello:

1. Ordenamos las capas del Dockerfile colocando primero las que menos vayamos a modificar. Esto nos permitirá invalidar menos veces la caché.
2. Tendremos una capa por cada script de instalación/configuración que ejecutamos, de forma que tenemos más puntos de caché, más reutilización. Esto puede ser perjudicial a nivel de tamaño de imagen pero como estamos en fase de desarrollo consideramos más importante una correcta organización y rápida iteración.
3. Si finalmente queremos optimizar el tamaño de la imagen (p.ej: para subirlo a un registro) podremos usar herramientas como `crane flatten`, `docker slim` y `docker squash` para reducir el número de capas.
