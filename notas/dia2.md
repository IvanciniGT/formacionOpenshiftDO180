# Contenedor

Entorno aislado dentro de un SO con kernel Linux donde ejecutamos procesos.

Aislado?
- Configuración de Red independiente del host
- Su propio sistema de archivos
- Sus propias variables de entorno
- Puede tener limitaciones de acceso a los recursos físicos del hierro (CPU, Memoria...)

Los contenedores los creamos desde una imagen de contenedor.

# Imagen de contenedor

Un archivo comprimido que suele tener dentro:
- Una estructura de carpetas POSIX (bin/ opt/ var/ home/...)
- Comandos de utilidad típicos de POSIX (sh cp wget more...)
- Otros programas instalados con sus configuraciones, dentro de esa estructura de carpetas (nginx, apache, mysql)

Además, la imagen de contenedor viene con metadatos:
- Fabricante
- Carpetas donde los programas que vienen instalados guardan sus datos (VOLUMENES)
- Puertos que usan esos programas por defecto
- Comando de arranque

URL completa de la imagen, que es lo que la identifica: registry/repo:tag

Y de los tags, dijimos que los hay de 2 tipos:
- Fijos         Siempre apuntan a la misma versión: 1.2.3
- Variables     Depende del momento del tiempo pueden apuntar a distintas versiones: latest, 1.2, 1

# Volúmenes

Un punto de montaje dentro del filesystem del contenedor (como si hacemos un mount de normal... para un nfs o lo que sea) que apunta a un almacenamiento (persistente o no - véase el caso de usar la RAM) ubicado fuera del contenedor (host, cloud, cabina...)

## Usos:

- Intercambio de información entre contenedores
- Inyectar archivos/carpetas a un contenedor (configuraciones, datos)
- Persistencia de información...tras el borrado del contenedor.

---

# Kubernetes

## Diferencia entre una herramienta como Docker, Podman y Kubernetes?

Docker, Podman son gestores de contenedores, que nos permiten crear, correr, gestionar contenedores en un host.
Pero en un entorno de producción no sirve tener solo un host... necesitamos un cluster (alta disponibilidad y escalabilidad).

Ahí es donde entra kubernetes. Kubernetes gestiona los gestores de contenedores de un conjunto de máquinas.

## Lenguaje Declarativo

Nosotros no somos los que le decimos a Kubernetes qué hacer... solo le decimos lo que queremos conseguir... el estado en el que queremos el cluster (eso lo hacemos con archivos YAML). La responsabilidad de conseguir ese estado es suya... y trabaja para ello 24x7... tomando sus propias decisiones (yo puedo influir de alguna forma en ellas).

## Pod

Conjunto de contenedores (puede ser solo 1) que:
- Comparten configuración de red
- Kubernetes los despliega en el mismo host
  - Pueden compartir volúmenes LOCALES
- Escalan juntos (lo que se escala es el pod... puedo crear más instancias de ese pod... o borrar instancias)

---

# Arquitectura de Kubernetes

Kubernetes no es un programa, sino una colección de programas.
Algunos de esos programas se instalan a hierro en el host.
Otros los instalamos como contenedores dentro del cluster.
Algunos de esos programas solo se instalan en ciertos nodos (nodos del plano de control, masters)
Otros se instalan en todos los nodos del cluster.

Entre ellos encontramos:
- Contenedores:
  - etcd:         La bbdd de kubernetes. Aquí guarda por ejemplo los archivos de manifiesto
  - coreDns:      Un servidor DNS interno de kubernetes
  - scheduler:    Se encarga de asignar los pods a los nodos del cluster
  - apiServer:    El servidor API de kubernetes, punto de entrada para la comunicación con el cluster (HTTP)
                  - Nosotros no mandamos peticiones http directamente a este programa... podríamos.. pero habitualmente usamos: 
                    - Dashboard gráfico
                    - Clientes de linea de comandos: kubectl, oc
  - controllerManager: Se encarga de la gestión del cluster.. de todas las operaciones necesarias
  - kubeproxy:     Se encarga de la comunicación entre los pods y también de las comunicaciones hacia a fuera.

- Instalados a hierro:
  - kubelet:       Se encarga de hablar con los gestores de contenedores que usemos (docker, containerd, crio)
  - kubectl:       Cliente
  - kubeadm:       Gestión del cluster(instalación, mnto)

CLUSTER DE KUBERNETES

Plano de control: (masters)
    Nodo1
        kubelet
        kubeadm
        kubeproxy
        etcd
        coreDNS
        scheduler
        apiServer
    Nodo2
        kubelet
        kubeadm
        kubeproxy
        etcd
        coreDNS
        scheduler
        controllerManager
    Nodo3
        kubelet
        kubeadm
        kubeproxy
        etcd
        apiServer
        controllerManager

Nodos de trabajo: (workers)
    Nodo4
        kubelet
        kubeadm
        kubeproxy
    Nodo5
        kubelet
        kubeadm
        kubeproxy
    NodoN
        kubelet 
        kubeadm
        kubeproxy

Por qué al menos 3 nodos para el plano de control?
El único programa de kubernetes que exige tener al menos 3 nodos es su base de datos (ETCD).
Esto es algo típico de cualquier sistema que almacene datos: BBDD, Sistema de colas de mensajes, indexador (ElasticSearch). 
El objetivo es evitar lo que llamamos un BRAIN SPLIT.

> Ejemplo de cluster activo/activo

    MariaDB1*   Dato1   Dato2   <---- Dato4
       v^
    MariaDB2    Dato1   Dato3   <----
       x
    MariaDB3    Dato2   Dato3   <---- Dato5

Básicamente, en un cluster como este, puedo mejorar el rendimiento (TEORICO) en un: 50% (x3 infra)
1 Máquina, 1 operación por unidad de tiempo
3 Máquinas, 3 operaciones en 2 ud. de tiempo

# YAML

Es un lenguaje para estructurar información. Similar en uso a XML o JSON.

YaML: YAML ain't Markup Language
 XML
HTML

  ML? Markup Language (Lenguaje de marcado <tag/>)

Es un lenguaje orientado a seres humanos.. que se está imponiendo en el mercado. Se ha comido a JSON... literalmente. JSON hoy en día es parte de la especificación de YAML (1.2)

Programas o herramientas que usan YAML: Kubernetes, Ansible, Azure Devops, Gitlab CI/CD, Configuración de red (UBUNTU)

# Objetos de configuración

- Node
- Namespace
- Pod
- Deployment
- StatefulSet
- DaemonSet
- ConfigMap
- Secret

## Comunicaciones

- Service
- Ingress
- Route (Openshift)

## Volumes

- PersistentVolumes
- PersistentVolumeClaims
- .. y más cosas.

# Hablaremos poco... pero algo
- HorizontalPodAutoscaler
- Job
- CronJob

# Hablaremos poco... casi nada

- ServiceAccount
- ResourceQuota
- LimitRange

---

# Namespace

Un namespace es un espacio de nombres.
Sirve para agrupar objetos dentro de un cluster, que queremos GESTIONAR de forma conjunta.

Más adelante veremos como:
- Podemos hacer que algunos usuarios solo puedan interactuar con ciertos namespaces.
- Podemos limitar el consumo de recursos de un namespace.

## Identificación de objetos en un cluster de kubernetes.

Cada objeto que creemos en un cluster va atener un NOMBRE (NAME). Ese nombre actúa como identificador del objeto.

Algunos (la inmensa mayoría) de los objetos que creamos en un cluster, van asociados a un namespace... salvo muy poquitas excepciones.

Dentro de un namespace solo podemos tener un objeto de un tipo concreto con un nombre.
No puedo tener dentro del mismo namespace 2 pods por ejemplo con el mismo nombre.
Por contra, SI podemos tener 2 pods con el mismo nombre si están en namespaces diferentes.
Si puedo tener un pod y un configMap con el mismo nombre, dentro del mismo namespace.

Es decir, en realidad, lo que actúa como identificador de un objeto es:
- Namespace
- Tipo de objeto (Pod, ReplicaSet, DaemonSet, Configmap...)
- Name del objeto

Hay algunos objetos... pocos que no van asociados a namespace, como por ejemplo los persistentVolume, Node, Namespaces. En ellos, se considera como identificador:
- Tipo de objeto (Pod, ReplicaSet, DaemonSet, Configmap...)
- Name del objeto

## Cómo creamos un namespace

```yaml

kind:            Namespace # Aquí ponemos el tipo de objeto que queremos configurar
apiVersion:      v1
                 # Aquí viene la librería de nuestro cluster de Kubernetes que se encarga de definir y controlar este tipo de objeto
                 # Los objetos que configuramos son controlados por librerías.
                 # Kubernetes viene con sus propios objetos, controlados por sus propias librerías, que vienen con kubernetes:
                 #  apps
                 #  batch
                 #  networking.k8s.io
                 #  autoscaling
                 # Esas librerías pueden tener distintas versiones
                 #  apps/v1
                 #  policy/v1beta1
                 # Cada librería me permite trabajar con ciertos tipos de objetos...
                 # Pero kubernetes también permite que se le extienda la funcionalidad mediante la instalación de nuevas librerías, que gestionen nuevos tipos de objetos (CRDs)
                 # Un fabricante externo (alguien que monta una cabina de almacenamiento), puede crear sus propias librerías de kubernetes
                 # para la gestión de sus volúmenes (huawei-volumes/v1)... Y quizás define un tipo de objeto llamado NFSSharedVolume
                 # Pero otro fabricante que también cree cabinas (emc2) podría tener definido un nuevo tipo de objeto
                 # que también se llame: NFSSharedVolume, solo que en este caso, ese tipo de objeto estaría definido dentro de su librería: 
                 # emc2-volumes
                 # Es la combinación Tipo de Objeto (kind) , librería que lo gestiona (apiVersion) la que me permite realmente identificar un Tipo de objeto.
                 # La sintaxis habitual del apiVersion es: `nombre-de-libreria/version`
                 # Salvo en el caso de la librería BASICA de kubernetes, donde solo escribimos la version: `v1`
metadata:
    name:        desarrollo  # Aquí ponemos el nombre del objeto que queremos configurar
```

# Pods

## Control de recursos:
```yaml
resources:
    requests:
        memory:         64Mi
        cpu:            250m
    limits:
        memory:         128Mi
        cpu:            2
```

- Requests:   Los recursos que se deben garantizar al pod (haga uso de ellos o no)
- Limits:     Lo que podría llegar a usar... si hay hueco!

Es importantisimo entender el impacto de estas definiciones.

El primero que tiene en cuenta esto es el **scheduler**.

> Ejemplo de despliegue en kubernetes

                   TOTAL           EN USO      SIN COMPROMETER  REQUEST  
                RAM     CPU     RAM     CPU     RAM      CPU    RAM    CPU
    Nodo1       10       4       4       2      2        0      
        pod1-nginx               2       1                       4      2
        pod2-nginx               2       1                       4      2
    Nodo2       10       4       8       4      0        0      
        pod3-nginx               4       2                       4      2
        mariadb                  6       2                       6      2

 En ellos, quiero desplegar:
    - pod nginx   
            requests:   4Gi     2000m 
            limits:     8Gi     4 
    - pod mariadb   
            requests:   6Gi     2000m 
            limits:     8Gi     4 

En scheduler solo mira los requests y los SIN COMPROMETER.
Además, el scheduler tiene en cuenta: El USO, los taints, los tolerations, las afinidades, las anti afinidades.

RECOMENDACION:
- Requests, lo que necesite mínimos mi programa para funcionar con un rendimiento aceptable.
- Limits:
    - RAM: EL MISMO VALOR QUE EN REQUEST... Esto no es nuevo... 
    - CPU.. lo que quiera

---


Cuánto he definido de limit de RAM? 4 Gibibytes.

    1 GB = 1000 MBs
    1 MB = 1000 KBs
    1 KB = 1000 B
    1 B = 8 bits

    Hace más de 25 años, era diferente:
    1 GB = 1024 MBs
    1 MB = 1024 KBs
    1 KB = 1024 B
    1 B = 8 bits

Y crearon una nueva unidad de medida: bibytes:
    1 GiB = 1024 MiB
    1 MiB = 1024 KiB
    1 KiB = 1024 Bi

Los bibytes son hoy en día lo que antiguamente eran los gibabytes, megabytes...
Van de 1024 en 1024...

---

> En un cluster tipo de kubernetes/openshift... cuántos pods voy a crear? NINGUNO!

Que yo pueda hacer algo... no significa que quiera hacerlo.
NUNCA creamos pods en un cluster de kubernetes.
Kubernetes es quién debe crear los pods, dentro de su cluster.
Si yo creo un pod... si el pod hay que moverlo, kubernetes no lo hará.
Si yo creo un pod, si hay que escalarlo, kubernetes no lo hará
Si yo creo un pod.. y se corrompe... kubernetes lo no lo recrea.

NUNCA CREAMOS PODS en un cluster.

Lo que haremos en su lugar es ofrecerle a KUBERNETES una PLANTILLA de mi pod... cómo quiero que sean mis pods.
Y Le pediremos a Kubernetes que él se encargue de crear los pods... y de su gestión.

Y kubernetes nos ofrece 3 objetos para configurar plantillas de pods:
- Deployments       Plantilla de pod + nº inicial de replicas (que posteriormente puedo cambiar)
- StatefulSets      Plantilla de pod + nº inicial de replicas (que posteriormente puedo cambiar) +
                    al menos 1 plantilla de persistentVolumeClaim
- DaemonSets        Plantilla de pod de la que kubernetes crea en automático tantas replicas como 
                    nodos tengo en el cluster... Monta una replica en cada nodo.

---

# Comunicaciones en un cluster de Kubernetes    


        Si alguien llama al 192.168.100.10:80 -> 
            http://192.168.100.101:30090
            http://192.168.100.102:30090
            http://192.168.100.103:30090
            http://192.168.100.201:30090
            http://192.168.100.202:30090
      Balanceador de carga
          | (externo al cluster)           miapp.miempresa.com -> 192.168.100.10
          |                                    |
      192.168.100.10                           |                       MenchuPC (http://miapp.miempresa.com)
          |                                   DNS Externo                 |
          |                                    |                    192.168.1.37
 +--------+------------------------------------+--------------------------+--- Red de la empresa (192.168.0.0/16)
 |
 |
 +--192.168.100.101--Nodo1 (Maestro)
 ||                      Linux
 ||                         NetFilter
 ||                             Cuando alguien quiera ir a 10.10.2.101:3307 -> 10.10.1.101:3306
 ||                             Cuando alguien quiera ir a 10.10.2.102:8080 -> 10.10.1.102:80, 10.10.1.103:80
  |                             Cuando alguien quiera ir a 10.10.2.103:8080 -> 10.10.1.104:80
 ||                             Cuando alguien acceda al 192.168.100.101:30090 -> 10.10.2.103:8080
 ||                      ContainerD
 ||                      Kubelet
 ||                      KubeProxy
 ||                      CoreDNS
 ||                         bbdd-service -> 10.10.2.101
 ||                         web-service  -> 10.10.2.102 
 ||                         ingress-controller-service  -> 10.10.2.103
 ||
 +--192.168.100.102--Nodo2 (Maestro)
 ||                      Linux
 ||                         NetFilter
 ||                             Cuando alguien quiera ir a 10.10.2.101:3307 -> 10.10.1.101:3306
 ||                             Cuando alguien quiera ir a 10.10.2.102:8080 -> 10.10.1.102:80, 10.10.1.103:80
  |                             Cuando alguien quiera ir a 10.10.2.103:8080 -> 10.10.1.104:80
 ||                             Cuando alguien acceda al 192.168.100.102:30090 -> 10.10.2.103:8080
 ||                      ContainerD
 ||                      Kubelet
 ||                      KubeProxy
 ||                      CoreDNS
 ||                        bbdd-service -> 10.10.2.101
 ||                        web-service  -> 10.10.2.102 
 ||                        ingress-controller-service  -> 10.10.2.103
 ||
 +--192.168.100.103--Nodo3 (Maestro)
 ||                      Linux
 ||                         NetFilter
 ||                             Cuando alguien quiera ir a 10.10.2.101:3307 -> 10.10.1.101:3306
 ||                             Cuando alguien quiera ir a 10.10.2.102:8080 -> 10.10.1.102:80, 10.10.1.103:80
  |                             Cuando alguien quiera ir a 10.10.2.103:8080 -> 10.10.1.104:80
 ||                             Cuando alguien acceda al 192.168.100.103:30090 -> 10.10.2.103:8080
 ||                      ContainerD
 ||                      Kubelet
 ||                      KubeProxy
 ||
 +--192.168.100.201--NodoWorker1 (Worker)
 ||                      Linux
 ||                         NetFilter
 ||                             Cuando alguien quiera ir a 10.10.2.101:3307 -> 10.10.1.101:3306
 ||                             Cuando alguien quiera ir a 10.10.2.102:8080 -> 10.10.1.102:80, 10.10.1.103:80
  |                             Cuando alguien quiera ir a 10.10.2.103:8080 -> 10.10.1.104:80
 ||                             Cuando alguien acceda al 192.168.100.201:30090 -> 10.10.2.103:8080
 ||                      ContainerD
 ||                      Kubelet
 ||                      KubeProxy
 ||                      Contenedores:
 ||--------------------------PodMariadb:     10.10.1.101:3306
 ||                              Contenedor: BBDD 
 ||--------------------------PodApache:     10.10.1.103:80
 ||                              Contenedor: ServidorWeb
 ||                                          En el fichero de configuración del wordpress, 
 ||                                          tengo que poner la URL de la BBDD a la que debe conectar:
 ||                                               mysql://bbdd-service:3307
 ||
 +--192.168.100.202--NodoWorker2 (Worker)
  |                      Linux
  |                         NetFilter
  |                             Cuando alguien quiera ir a 10.10.2.101:3307 -> 10.10.1.101:3306
  |                             Cuando alguien quiera ir a 10.10.2.102:8080 -> 10.10.1.102:80, 10.10.1.103:80
  |                             Cuando alguien quiera ir a 10.10.2.103:8080 -> 10.10.1.104:80
  |                             Cuando alguien acceda al 192.168.100.202:30090 -> 10.10.2.103:8080
  |                      ContainerD
  |                      Kubelet
  |                      KubeProxy (Va configurando los netfilter de cada máquina)
  |                      Contenedores:
  |--------------------------PodApache:     10.10.1.102:80
  |                              Contenedor: ServidorWeb
  |                                          En el fichero de configuración del wordpress, 
  |                                          tengo que poner la URL de la BBDD a la que debe conectar:
  |                                               mysql://bbdd-service:3307
  |--------------------------PodProxyReverso: 10.10.1.104:80
  |                              Contenedor: IngressController - Nginx
  |                                             Necesitamos una regla:
  |                                                 Si llega una petición dirigida a : miapp.miempresa.com  \
  |                                                 La rediriges a web-service:8080                         / INGRESS
  |
  Red virtual del cluster de kubernetes: 10.10.0.0/16

Quiero desplegar en este cluster un Wordpress (montar una web):
- BBDD (MariaDB)
- Servidor Web: Apache

Montar un Service: 

 - ClusterIP:   IP de balanceo de carga + Entrada en el DNS interno de Kubernetes

    bbdd-service (ese nombre es el que registra en el DNS de kubernetes) -> IP 10.10.2.101
    web-service (ese nombre es el que registra en el DNS de kubernetes) ->  IP 10.10.2.102

 - NodePort:    ClusterIP + Puerto nat por encima del 30000 que se configura en cada host
 - LoadBalancer:  NodePort + Gestión automatizada de un balanceador externo de carga COMPATIBLE CON KUBERNETES.

- Ingress: Regla de configuración para un proxy reverso (Ingress Controller)

- Route: Es una gestión automatizada de un DNS Externo compatible con Openshift.
          En kubernetes ESTANDAR no hay nada así... Aunque hoy en día hay un proyecto OFICIAL de Kubernetes que nos permite hacer lo mismo 
Si contrato un cluster de Kubernetes (Openshift) a un cloud, el cloud me da siempre (€€€) un balanceador de carga compatible con Kubernetes.
Pero, si monto yo mi propio cluster (on prem) necesito montar yo un balanceador de carga compatible con Kubernetes: MetalLB.


   En un cluster tipo de Kubernetes u Openshift... cuántos (% o valor absoluto) servicios tendré de cada tipo

                       Cuántos
    ClusterIP:         Todos menos 1
    NodePort:          0
    LoadBalancer:      1               < Proxy Reverso (Ingress Controller)
