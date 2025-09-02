
# Qué es un Contenedores?

Es un entorno aislado dentro de un SO (con kernel Linux) donde ejecutar procesos.
Aislado en cuanto a qué? Los procesos que corren dentro de un contendedor tienen:
- Acceso a un RED independiente de el resto de interfaces del HOST, con sus propias IPs.
- Tienen su propio sistema de archivos, independiente del del HOST.
- Tienen sus propias variables de entorno
- Pueden tener limitaciones en cuanto al acceso a los recursos físicos del host (RAM, CPU...)

## Para qué sirve?

La contenedorización es la alternativa para el despliegue / instalación de software.

## Procedimientos de instalación de software

### Forma tradicional: Instalación a hierro

        App1 + App2 + App3
    -------------------------
        Sistema Operativo
    -------------------------
              HIERRO


Problemas gordos:
- Qué ocurre si una app (App1) tiene un bug? (CPU 100%) ---> App1 OFFLINE (App2, App3 ---> OFFLINE)
- Incompatibilidad de las apps / sus dependencias
- Incompatibilidad en las configuraciones a nivel de SO que requieren
- Seguridad

### Máquinas virtuales

        App1   | App2 + App3
    -------------------------
        SO     |      SO
    -------------------------
        MV1    |      MV2
    -------------------------
        Hipervisor:
        VMWare, Citrix, VBox,
        HyperV...
    -------------------------
        Sistema Operativo
    -------------------------
              HIERRO

Esta forma de trabajo me resuelve los problemas que nos ofrecen las instalaciones a Hierro... pero a qué coste?
- Instalación del entorno/configuración es mucho más compleja que en las instalaciones a Hierro.
- Mantenimiento complicado.
- Merma de recursos
- Menor rendimiento que con las instalaciones a hierro.

### Contenedorización


        App1   | App2 + App3
    -------------------------
        C1     |      C2
    -------------------------
      Gestor de contenedores:
      Docker, ContainerD, 
      Podman, CRIO
    -------------------------
     Sistema Operativo Linux
    -------------------------
              HIERRO

Esto nos resuelve los mismos problemas que nos resolvían las MV con respecto a las instalaciones a hierro...
Pero sin el sobrecoste de las máquinas virtuales.

DECISION a nivel industria: TODO LO QUE PUEDA A CONTENEDORES... Y el 90% de los usos anteriores MVs han sido reemplazados por contenedores.
VMWare tiene su propia distro de Kubernetes (competencia directa de Openshift: Tanzu)

Hay más gracias en esto de los contenedores:
- Un contenedor se crea desde una imagen de contenedor. No es nuevo... Una VM la creamos desde una imagen de disco.
- Además, esas imágenes de contenedor están estandarizadas. Da igual el programa con el que las cree, funcionan en todos los gestores de contenedores. (En el mundo de las VMs... trabajamos con ISOs... que también son estandar.)

### Imágenes de contenedor:

Una imagen de contenedor es un triste fichero comprimido (tar) que tiene dentro:
- Una estructura de carpetas compatible con POSIX (no obligatorio... pero es lo que vais a encontrar en el 95% de los casos)
   /        root
    bin/
        ls
        mv
        cp
        chmod
        sh
        dnf
        yum
        bash
        apt
        ...
    etc/
        apache/
            apache.conf
    opt/
        apache/
            apache (binario)
    var/
        www/
            index.html
    tmp/
    home/
    usr/
- Y dentro de ella, programas y archivos de configuración.

Además, dentro de la imagen de contenedor vienen algunos metadatos:
- Algunos un poco chorras: Fabricante de la imagen...
- Otros importantes:
  - En qué carpetas los programas que vienen instalados/configurados dentro de la imagen guardan los archivos por defecto
  - Qué puertos usan por defecto
  - Cuál es el comando que arranca el programa que viene ahí dentro preinstalado.

Instalación MONGODB:
- Descargar el "instalador"
- Preparo dependencias/configuraciones
- Ejecuto instalador (lo que puede ser más o menos complejo... depende del programa)
- Eso da lugar a una instalación.      c:\Archivos de programa\Mongo ---> ZIP
- La arranco. ¿Cómo se arranca el programa que he instalado?

Dentro de una imagen de contenedor VIENE UN PROGRAMA YA INSTALADO DE ANTEMANO (normalmente instalado por el fabricante)... Además incluye las dependencias, con sus configuraciones...

Esas imágenes de contenedor las encontramos en REGISTROS DE REPOSITORIOS DE IMÁGENES DE CONTENEDOR:
- Docker hub
- Quay.io     (es el docker hub... de redhat)
- Microsoft Artifact Registry
- Oracle Container Registry
Todo producto de software empresarial hoy en día se distribuye mediante imágenes de contenedor!

# Identificar una imagen de contenedor

Se identifican por una URL:

        mcr.microsoft.com/mssql/server:2025-RC0-ubuntu-24.04
        REGISTRY: mcr.microsoft.com
        REPOSITORIO: mssql/server
        TAG: 2025-RC0-ubuntu-24.04

Lo único que nos exigen los gestores de contenedores que pongamos es el repo... es la única parte obligatoria.
Si pongo como url de una imagen: "apache"
Ese "apache" se entiende por el gestor de contenedores como el REPO. Ese repo lo buscará en algún REGISTRY que el gestor de contenedores tenga configurado (ESTATICAMENTE, en sus ficheros de configuración)
Si no ponemos el TAG, por defecto se busca el tag: "latest"

Ese tag no es ninguna palabra mágica... no es una referencia a la última imagen que se haya publicado... solo es un valor por defecto... que puede ni existir en el repo.

## Tags en imágenes de contenedor.

Esa parte, el que publica la imagen (el que la sube al registry) pone el tag que quiere... formato libre.
Usualmente encontramos dentro del tag:
- Información de la versión del producto que vienen instalada
- En ocasiones, encontramos información de la imagen base que se utilizó para crear la imagen (debian, ubuntu, oracle linux, alpine)
  En entornos de producción es muy habitual tirar de imágenes alpine... pesa mucho menos. 
- Versiones de otras dependencias:
  - JAVA
- Otras dependencias/utilidades

Hay 2 tipos de tags: Tags fijos y tags variables!

latest/stable   <--- Ese es variable
1               <--- Ese es variable
1.2             <--- Ese es variable
1.2.3           <--- Es un tag fijo..... Siempre apunta a esa versión concreta.

Los tags variables, en distintos momentos del tiempo pueden apuntar a distintas versiones del producto.

En la mayor parte de los productos de software, para controlar la versión del producto se usa lo que llamamos el esquema semántico de versiones:

    a.b.c
                    Cuándo cambian?
    Major: a        Cambios que rompen retrocompatibilidad. BREAKING-CHANGES
    Minor: b        Nueva funcionalidad
                    o Funcionalidad marcada como OBSOLETA (deprecated)
                        Aquí también pueden venir bugfixes... 
    Patch: c        Arreglos de bugs. Bugfixes.

De los tags anteriores, cuál sería bueno para un entorno de producción:

    latest/stable   <--- FATAL... En un momento puede apuntar a la versión 1.2.3... y al mes siguiente apuntar a la versión 2.0.1
                            La nueva versión puede traer Breaking changes... básicamente no tengo npi de qué versión se va a instalar.
    1               <--- MAL..... En un momento dado, puede apuntar a la versión 1.2.3 y al mes siguiente apuntar a la 1.3.0
                            Me viene nueva funcionalidad... que no estoy usando, que no necesito... que puede traer nuevos bugs.
    1.2             <--- BASTANTE BIEN. 
                            En un momento dado puede estar apuntando a la 1.2.3 y al mes apuntar a la 1.2.17
                            Trae la funcionalidad que necesito, y me aseguro que siempre tengo la versión con más bugs resueltos.
    1.2.3           Esta opción está guay para producción... aunque es un poco conservadora.. quizás demasiado.

## Redes con contenedores.

Los contenedores se pinchan a una interfaz de red ... a priori la que yo quiera... por defecto a una red virtual que el gestor de contenedores crea en el host.
                                                                                                        MenchuPC
                                                                                                          |
                                                                                                192.168.3.218
                                                                                                          |
   +---------------------------------------- Red de la empresa -------------------------------------------+
   |    
   IP: 192.168.3.217
   |     NAT 192.168.3.217:1234 ---> 172.17.0.2:80
   |
  HOST - 172.17.0.1 ----------- Red virtual del gestor de contenedores: DOCKER 172.17.0.0/16 -----+
   |                                                                                              |
   |                                                                                            172.17.0.2 - minginx
   127.0.0.1 (localhost)
   |
   | Red de loopback (Red virtual)

# Sistema de archivos de un contenedor


ROOT HOST : /
    bin/
        ls
        mv
        cp
        chmod
        sh
        dnf
        yum
        bash
        apt
        ...
    etc/
        docker
            docker.conf
    opt/
        docker/
            docker (binario)
    var/
        lib/
            docker/
                containers/
                    minginx/ ***
                        etc/
                            nginx/
                                nginx.conf
                        var/
                            nginx/
                                nginx.log
                    minginx2/ ***
                        etc/
                            nginx/
                                nginx.conf
                        var/
                            nginx/
                                nginx.log
                images/
                   nginx:latest/ <------ Se hace creer al contenedor que esta carpeta es el ROOT de su sistema de archivos: chroot
                        bin/
                            ls
                            mv
                            cp
                            chmod
                            sh
                            dnf
                            yum
                            bash
                            apt
                            ...
                        etc/
                            nginx/
                                nginx.conf
                        opt/
                            nginx/
                                nginx (binario)
                        var/
                            www/
                                index.html
                        tmp/
                        home/
                        usr/
    tmp/
    home/
    usr/


En realidad es un poco más complejo. sa carpeta que se descomprime desde la imagen del contenedor NO SE PUEDE ALTERAR.
No puedo borrarle archivos, ni crearle, ni editarlos.

Los gestores de contenedores crean una carpeta para cada contenedor. En ella guardan los cambios que se realicen sobre el sistema de archivos descomprimido de la imagen del contenedor.

El gestor de contenedores, cuando me muestra (me da acceso) al sistema de archivos de un contenedor, lo que muestra es la superposición de esas 2 carpetas.

## Los contenedores... tienen persistencia de los datos?

SI... la misma que las máquinas físicas o virtuales.... hasta que borre el contenedor.

El tema es que al trabajar con contenedores, la operación de borrar un contenedor es el pan nuestro de cada dia.. Un contenedor lo borramos 20 veces al día:
- Mover el contenedor de un host a otro
- Operaciones de escalado horizontal
- Actualizaciones de software


### VOLUMENES en contenedores.

Es un punto de montaje en el sistema de archivos del contenedor que apunta a un almacenamiento físico fuera del sistema de archivos del contenedor.
LO MISMO QUE SI EN UN HOST LINUX monto una carpeta nfs con mount.

$ mount -t nfs RUTA_REMOTA RUTA_LOCAL

Ese sitio externos puede ser:
- Una carpeta en el sistema de archivos del host (LO MAS HABITUAL cuando trabajamos con Docker)
- Una carpeta en red (nfs) 
- Un volumen de disco en un iscsi o cloud
- Un trozo de RAM del host (Esto es guay).

Al crear un contenedor, puedo vincularle esos volumenes a su sistema de archivos.

### Para qué sirven los volúmenes?

- Persistir datos tras la eliminación del contenedor
- Compartir datos entre contenedores

    HOST 1
        Apache httpd1/Tomcat1/Weblogic1
                    VVVV
            ---> access.log (RAM: 2 log rotados de 50kbs)                                   Logstash  > ElasticSearch < Kibana
                    ^^^^
        Filebeat1

    HOST 2
        Apache httpd2/Tomcat2/Weblogic2
            ---> access.log
        Filebeat1
- Inyectar carpetas o archivos a un contenedor (por ejemplo, configuraciones: nginx.conf, mysql.conf)


# Qué es Linux?

Linux no es un Sistema Operativo. Linux es un KERNEL de SO. Todo sistema operativo tiene un Kernel.

Con ese Kernel se montan muchos sistemas operativos.
- GNU/Linux <--- Distribuciones como Ubuntu, CentOS, Fedora, RHEL...
- Android
- Windows 

# Qué era UNIX?

Un sistema operativo, que creaba la gente de AT&T (en los laboratorios Bell). Ese sistema operativo no se licenciaba comose licencian actualmente. Hoy en día tenemos el concepto de EULA (End User License Agreement). Antiguamente se licenciaban a empresas u organizaciones.
Llegó a haber más de 400 versiones diferentes... y empezaron a mostrar incompatibilidades entre si.
Y para resolverlos salieron unos estándares, a cerda de cómo debía evolucionar un SO UNIX: SUS + POSIX

# Qué es UNIX?

Un SO Unix es un SO que cumple con dichos estandares.

IBM: AIX   (UNIX®)
HP:  HP-UX (UNIX®)
Oracle: SOLARIS (UNIX®)
Apple: Mac-OS (UNIX®)




---



- Compatibilidad hardware
- Recursos limitados de computo/almacenamiento
- Carga extra del SO...

-----

Todo esto... del docker... NO VALE PARA UN ENTORNO DE PRODUCCION!

# Entornos de producción:

- Alta disponibilidad:

    Capacidad de un sistema para mantenerse funcionando (prestando servicio) un determinado tiempo establecido previamente (SLA).
    Se suele medir en 9s. Aunque esas medidas son más de carácter informativo.

        Sistema con una disponibilidad del 90% (36,5 días al año con el sistema offline)                            | €
        Sistema con una disponibilidad del 99% (3,65 días al año con el sistema offline) - Peluquería de barrio     | €€
        Sistema con una disponibilidad del 99,9% (8,76 horas al año con el sistema offline) - Mercadona             | €€€€€€€
        Sistema con una disponibilidad del 99,99% (52,56 minutos al año con el sistema offline) - Hospital          | €€€€€€€€€€€€€€€€€€
                                                                                                                    v

    Esto es la carta a los reyes magos.

    Asegurar / Tratar de asegurar la no pérdida de información.

    Todo esto lo conseguimos con REDUNDANCIA: CLUSTER

- Escalabilidad

    Capacidad de ajustar la INFRA a las necesidades de cada momento.

    App1: app de un hospital para que los medicos metan los datos.
        día 1:      98 usuarios
        día 100:    102 usuarios            NO HACE FALTA ESCALABILIDAD... pero no hay tantas
        día 1000:   100 usuarios

    App2: Cualquier app que va teniendo éxito... Netflix... Facebook
        día 1:      100 usuarios
        día 100:    1000 usuarios           Aquí nos hace falta escalabilidad VERTICAL: más máquina!
        día 1000:   10000 usuarios

    App3: App emergencias... app telepi
        día n:    100 usuarios
        día n+1:  1000000 usuarios
        día n+2:  0 usuarios
        día n+3:  10000000 usuarios
        
    TELEPI:
        00:00 - 0 usuarios
        09:00 - 0 usuarios
        12:00 - 5 usuarios
        14:00 - 5000 usuarios                Aquí necesito escalabilidad HORIZONTAL: más o menos máquinas! CLUSTER
        16:30 - 50 usuarios
        21:00 - Madrid vs Barça... agarra que nos vamos 10000000
        00:00 - 0 usuarios

        Los Clouds son los que me permiten adquirir máquinas bajo demanda... con un modelo de pago por uso.

Docker... y sus similares (amiguitos: Podman, crio, containerd...) son gestores de contenedores... Me permiten ejecutar contenedores en 1 host.

Aquí es donde necesito otras capacidades diferentes: Kubernetes.

Kubernetes es un gestor de gestores de contenedores.

Cluster de Kubernetes
    NODO A                          \
        kubernetes                   |
    NODO B                           | Nodos maestros 
        kubernetes                   |
    NODO C                           |
        kubernetes                  /

    NODO 1                          \
        containerd                   |
    NODO 2                           | Nodos trabajadores
        containerd                   |
    NODO 3                           |
        containerd                   |
    NODO 4                           |
        containerd                   |
    NODO n                           |
        containerd                   /

Y lo que voy a hacer es pedir a kubernetes que gestione esos gestores de contenedores.
Le diré:
Quiero tener 3 apaches desplegados en mi cluster...
Y Kubernetes, elige 3 nodos donde desplegar esos apaches, habla con sus correspondientes containerd y les pide que los desplieguen.
Monitoriza si alguno de esos apache o nodos deja de funcionar y toma las medidas necesarias para mantener la disponibilidad: Mueve(borra y crea nuevos) contenedores a otros nodos si es necesario.
Gestiona la escalabilidad de los contenedores, pidiendo a los gestores de contenedores que creen o borren contenedores según la demanda.

Cuando voy a un entorno de producción, y quiero operar con contenedores, necesito una solución de este tipo.

Pero... esto no es nuevo... lo llevamos haciendo décadas.... el montar entornos de producción, con alta disponibilidad y escalabilidad, es algo que hemos estado abordando desde hace tiempo. Y claro... el montar un entorno así, necesita de piezas adicionales... que ya conocemos!

    FORMA TRADICIONAL
                            Al conjunto de PODs : Deployment/StatefulSet/ReplicaSet
                        Nodo1
                          Nginx1
                            app1
  Almacenamiento        Nodo2           Balanceador de carga        Proxy Reverso       |      Proxy           Cliente (Menchu)
  Compartido              Nginx2                                                                192.168.1.100   192.168.200.123
                            app1
                        Nodo3
                          Nginx3
                            app1
                        Nodo4
                          Nginx4. POD
                            app1

  VOLUMES                                 SERVICE                  INGRESS CONTROLLER

Proxy: El proxy es una pieza de software que está para proteger al cliente
Proxy reverso: Protege el entorno


Un punto crítico, fundamental, especial de Kubernetes... Lo mejor que tiene... y lo que a veces más nos cuesta entender...
KUBERNETES HABLA LENGUAJE DECLARATIVO.

Lo que intentamos es automatizar tareas.



# DEVOPS

Es una cultura, es una filosofía... es un movimiento que defiende la automatización!

Automatizar?

Montar una máquina o configurar una mediante un programa para que haga la labor que antes hacía un humano.

LAVADOORA! Automatiza el proceso de lavado de ropa.
COMPUTADORAS <- PROGRAMAS

Esto tampoco es nuevo... hace 40 años ya hacíamos programas de automatización... que leches es un script de la BASH?

Básicamente nuestro trabajo ahora es crear programas.
Ya no administramos sistemas... Ahora creamos programas que administren sistemas... o Usamos programas que administren sistemas (KUBERNETES) y solo los configuramos.

Ya no hay humanos operando los entornos de producción. Ese trabajo es de kubernetes. Nuestro trabajo ahora es decirle a kubernetes cómo queremos el entorno de producción = HACER UN PROGRAMA

Y los programas los hemos hecho siempre con lenguajes de programación: BASH, BAT, PS1, PYTHON.

Esos lenguajes de ahí, usan lo que llamamos un paradigma IMPERATIVO!
Hay muchos paradigmas... que no son sino nombres horteras que los desarrolladores le ponemos a la forma en la que estamos usando o podemos usar un lenguaje... Pero eso nos pasa igual con los lenguajes humanos.

> SI(IF) algo=true debajo de la ventana,
    >  QUITALO (Imperativo)
> SI(IF) no silla debajo de la ventana,            CONDICIONALES
> IF haySilla = false:  
>   GOTO IKEA! compras silla
> FELIPE, pon una silla debajo de la ventana!      IMPERATIVO


 mkdir:  make directory                            IMPERATIVO 
 cd:     change directory




Odiamos el lenguaje imperativo... aunque estamos muy acostumbrados a él.
Es un asco... porque me hace perderme de mi objetivo.

Cuál es mi objetivo con esa orden... detrás de esa orden: Tener una silla debajo de la ventana

FELIPE, debajo de la ventana tiene que haber una silla!     DECLARATIVO (Enunciativo afirmativo)

Esa frase es muy poderosa... porque estoy transfiriendo la RESPONSABILIDAD de conseguir ese objetivo a Felipe!

En Kubernetes declaramos configuraciones (MANIFIESTOS - YAML).
Kubernetes recibe esas INDICACIONES, esos manifiestos... y a partir de ahí su única misión es conseguir que mi entornos cumpla con ello...
Y va a trabajar 24x7 para conseguirlo.

Esas cosas que podemos configurar en kubernetes, tienen nombre:
- Namespace
- Pod
- Deployment
- Statefulset
- DaemonSet
- Job
- CronJob
- Volume
- PersistenVolume
- PersistentVolumeClaim
- ConfigMap
- Secret
- Service
- Ingress
- NetworkPolicy
- Resource Quota **
- LimitRange     **
- HorizontalPodAutoescaler
- PodBudgets
- ServiceAccount
- ...

Esas son las cosas de kubernetes... unas 25-30.

Una cosa bonita de kubernetes es que es EXTENSIBLE.
Kubernetes permite que otros (terceros) definan nuevas configuraciones (nuevos objetos que puedo configurar)... y que le explican a kubernetes cómo proceder cuando se configuren esas cosas. CRDs (Custom Resource Definitions)

Openshift es solo un kubernetes (con sus 25-30 cosas estandar) + 200 o 300 adicionales que ofrece Redhat
    Project, Machine, MachineSet, User, Route
Tanzu es solo un kubernetes (con sus 25-30 cosas estandar) + 200 o 300 adicionales que ofrece VMWare

---

# Qué es un POD?

Un conjunto de contenedores (al menos 1), que:
- Comparten configuración de red... y por ende IP... Entre ellos pueden hablar con la palabra "localhost"
- Se despliegan en el mismo host (está garantizado)
  - Pueden compartir almacenamiento local (volúmenes)
- Escalan juntos.

Quiero montar un wordpress: Apache httpd, mysql

Pregunta... Cuántos contenedores? 1 o 2?
- Necesito que estén juntos en el mismo contenedor? NO... entonces SIEMPRE SEPARADOS.

Siguiente: Cuántos pods? 1 o 2
2 pods... claramente:
- Comparten configuración de red... y por ende IP... Entre ellos pueden hablar con la palabra "localhost"    NO HAY NECESIDAD
- Se despliegan en el mismo host (está garantizado)                                                          NO HAY NECESIDAD
  - Pueden compartir almacenamiento local (volúmenes)                                                        NO HAY NECESIDAD
- Escalan juntos.                                                                                            NO ES DESEABLE

Quiero desplegar apaches (que generan access.log), junto con filebeats (que los leen para mandarlos a un elasticsearch): 1 o 2 pods?
- Comparten configuración de red... y por ende IP... Entre ellos pueden hablar con la palabra "localhost"    NO HAY NECESIDAD
- Se despliegan en el mismo host (está garantizado)                                                          SI HAY NECESIDAD
  - Pueden compartir almacenamiento local (volúmenes)                                                        SI HAY NECESIDAD
- Escalan juntos.                                                                                            ES OBLIGATORIO

Decisión: 1 UNICO POD!

En muchos casos, tendremos pods con un solo contenedor.




