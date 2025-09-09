
# Contenedor

Entorno aislado dentro de un SO (principalmente con Kernel Linux) donde ejecutar procesos... los que necesite.
El proceso con el que arranca el contenedor, su proceso principal, viene definido en la imagen del contenedor... aunque yo puedo sobreescribirlo al crear el contenedor desde la imagen.

Entorno aislado?
- Configuración independiente del host de la red (Su propia ip...)
- Sus propias variables de entorno
- Se pueden configurar limitaciones de acceso a los recursos físicos del host
- Sistema de archivos independiente al del host

Un contenedor puede ejecutar dentro (puede llevar) un SO? Yo no puedo ejecutar un SO completo dentro de un contenedor. Esa es la gran diferencia con respecto a las máquinas virtuales. Cuando trabajo con contenedores, los procesos que tengo el contenedor son gestionados y están en comunicación con el kernel de SO que hay a nivel del HOST. En la máquina (en un nodo) solo hay un kernel de SO.

Un contenedor se crea desde una imagen de contenedor.

# Imágenes de contenedor

Un triste fichero comprimido (tar) que suele llevar dentro:
- Una estructura de directorios POSIX (no es obligatorio... pero es lo que vemos siempre)
  Entre otras cosas, es lo que vemos siempre ya que las imágenes de contenedor de apps suelen crearse desde lo que llamamos IMAGENES BASE de contenedor, como por ejemplo: UBUNTU (30Mbs), ALPINE(3Mbs), ORACLELINUX, FEDORA (60Mbs)
- 4 comandos básicos de linux: wget, ls, cat
- Si acaso un gestor de paquetería (yum, apt, dnf, snap...)
- Al menos una sh. Algunos pueden llevar shells más avanzadas: bash, fish
- El software que quiero ejecutar dentro del contenedor (nginx, mysql, redis...)

Adicionalmente llevaba unos metadatos:
- El comando que debe arrancarse al iniciar el contenedor
- Puertos que vienen preconfigurados (documentación)
- Las carpetas donde los programas que vienen preinstalados guardan sus archivos (VOLUMENES - Documentación)
- Valores por defecto de algunas Variables de entorno
- Fabricante, url... licencia.

La gente que desarrolla nginx, cuando quiere publicar una imagen de contenedor que tenga nginx, lo que hace es:
1. Toma una imagen base de contenedor (Ubuntu, Alpine...)
   Ahí dentro viene ya las carpetas típicas de linux: /etc, /bin, /usr, /var... y los comandos básicos de linux.
2. Sobre esa estructura de carpetas, instala nginx y sus dependencias.
3. Genera un nuevo comprimido (tar) con todo eso.

Las imágenes las descargo de un registro de repositorios de imágenes de contenedor, como Docker Hub, Quy.io, Microsoft Artifact Registry, Oracle Container Registry...

# Volúmenes

## Qué son?

Un punto de montaje en el FS del contenedor... apuntando a un recurso de almacenamiento externo.

## Para qué los uso?

- Persistencia de datos... si es que la quiero.
- Compartir información entre contenedores.
- Inyectar configuraciones, archivos, carpetas dentro de un contenedor

---

Los contenedores se ejecutan/crean/gestionan mediante un gestor de contenedores (Docker, Podman, CRI-O, Containerd...)
Pero esos gestores de contenedores no vienen preparados para las necesidades de un entorno de producción:
- Alta disponibilidad
- Escalabilidad
- Seguridad mejorada

Ahí es donde entra Kubernetes.

---

# Arquitectura de un cluster de kubernetes

Kubernetes no es un programa... son muchos programas.
- Kubelet: Demonio que se ejecuta en cada nodo del cluster y cuya misión es hablar con los gestores de contenedores para ir creando contenedores en los nodos. Se instala a Hierro (Desde el SO)
- Kubectl: Cliente de linea de comandos para hablar contra un cluster de kubernetes. Se instala a hierro.
- Kubeadm: Herramienta para facilitar la instalación y configuración de más bajo nivel un cluster de kubernetes (el añadir nuevos nodos... renovar certificados de comunicación entre ellos).

## Plano de control de Kubernetes:

Contenedores que ejecutan otros programas que también forma parte de kubernetes. Principalmente se instalan en los nodos maestros... salvo alguno que también se instala en los workers.
- CoreDNS: Servicio de DNS para el cluster.
- Etcd: BBDD clave-valor distribuida que almacena la configuración y el estado del cluster.
- ApiServer: Esta es la puerta a kubernetes. Toda comunicación con el cluster es recibida por el ApiServer.
  Nota: kubectl, el dashboard gráfico, oc... todos ellos se comunican con el apiServer.  
- Scheduler: Es el que asigna los pods a los nodos.
  De hecho... por defecto hay un scheduler... pero en kubernetes puedo definir varios schedulers, con distintas configuraciones... y al hacer un despliegue decidir que scheduler utilizar.
- Controller Manager: El cerebro de kubernetes. Se encarga de gestionar los controladores que regulan el estado de los recursos en el cluster.
- Kubeproxy: Ayuda en las comunicaciones... Daba de alta reglas de comunicación en NetFilter.
  Donde se instala? Se instala en los maestros y también en los workers.
Estructura de un cluster

- Nodos Maestros (al menos 3)

- Nodos Trabajadores (Worker Nodes)

## Darle instrucciones a Kubernetes

Kubernetes define objetos de configuración (recursos) para ir definiendo mi entorno de producción.
Kubernetes es quién gestiona ese entorno de producción.

Esos objetos de configuración los defino en un lenguaje DECLARATIVO... 
Y en concreto, Kubernetes usa YAML como lenguaje para definir esos objetos.

Kubernetes permite que programas externos definan nuevos objetos de configuración (recursos): Custom Resource Definitions (CRDs). Esto es lo que permite extender la funcionalidad de Kubernetes (De hecho esto es lo que hacen Openshift, Tanzu, Karbon, AWK)

Kubernetes viene con los siguientes tipos de recursos:
- Namespace                     Es un grupo lógico de recursos dentro del cluster, para facilitar tareas de mnto y gestión. 
                                Aunque también tiene implicaciones en las comunicaciones.
- Node
- Secret                        \ Se guardan pares CLAVES-VALOR, que puedo usar posteriormente para:
- ConfigMap                     /                               - Inyectar configuraciones dentro de contenedores como variables de entorno
                                                                - Inyectar archivos o carpetas dentro de contenedores (Usándolos como volúmenes)
- PersistentVolume              La declaración que hacemos en kubernetes de un volumen que existe Fuera de kubernetes (cabina, aws, iscsi, nfs)
                                Hoy en día, los adminstradores del cluster no andan jodiendo creando volúmenes... en su lugar lo que hacen es instalar un provisionador automatizado de volúmenes. Ese provisionador se encarga:
                                - Generar el volumen en el backend de turno
                                - Registrarlo en Kubernetes (dar de alta el pv)
                                Estos provisionadores van asociados a un StorageClass.
- PersistentVolumeClaim         Una petición de un volumen que solicita un desarrollador o negocio.
- StorageClass
- Deployment                    Una plantilla de pod + número inicial de réplicas.
- Statefulset                   Una plantilla de pod + Al menos 1 plantilla de petición de volumen persistente + número inicial de réplicas.
- DaemonSet                     Una plantilla de pod, de la que kubernetes genera una réplica por nodo.
- Pod                           Conjunto de contenedores que:
                                - Comparten configuración de red (IP)
                                - Se despliegan en el mismo host
                                  - Pueden compartir volúmenes locales
                                - Escalan juntos
                                Los procesos de los contenedores de un pod no puede acabar nunca... Se considera un demonio o servicio... y si acaba kubernetes entiende que algo ha fallado.
                                Dentro de los pods, tenemos la oportunidad de ejecutar comandos o scripts? InitContainers
- Job                           Es el mismo concepto que un pod... 
                                solo que los contenedores que define deben ejecutar como comando un proceso que finalice en el tiempo (comando, script)
- CronJob                       Plantilla de job + programación en el tiempo
- Service 
  - ClusterIP                   IP interna al cluster de balanceo + Entrada en DNS Interno. 
                                Se usa para comunicaciones internas
  - NodePort                    ClusterIP + Nat a nivel de cada nodo del cluster (en un puerto > 30000). 
                                Se usa para exponer servicios al exterior
  - LoadBalancer                NodePort + Gestión automatizada de un balanceador de carga externo al cluster
- Ingress                       Regla de configuración para un proxy reverso.
                                (IngressController = ProxyReverso + Programa que traduce los Ingress al formato/sintaxis propia del ProxyReverso que venga dentro del IngressController        )
- HorizontalPodAutoscaler
- LimitRange
- ResourceQuota
- ServiceAccount                Es la identificación que he de suministrar al apiServer, cuando quiero hablar con él.
- Role
- RoleBinding
- ClusterRole
- ClusterRoleBinding
- NetworkPolicy
- PodDisruptionBudget
- VolumeSnapshotClass
- VolumeSnapshot


---

Identificación                  Decir quien soy                                                 ServiceAccount
Autenticación                   Demostrar que soy quien digo ser                                    Tokens de seguridad asociados al SA
Autorización                    Sabiendo que eres quien dices ser, decidir qué puedes hacer!        RoleBinding / ClusterRoleBinding
Operaciones que puedo hacer en concreto: Lo que puede ser hecho!                                    Role / ClusterRole

Role/ClusterRole:               Listado de tipos de objetos en kubernetes + verbos permitidos para ellos:
            Pod         create, watch, delete
            Pv          watch, list

---
- Influir en el scheduler
  - Request de Recursos que definamos en los pods... y que haya disponibles (sin comprometer) en los nodos
  - Taints/Tolerancias
  - Afinidad
- Planificación de un cluster (PODS X NODOS)
  - Taints/Tolerancias          Operadores del cluster
    Sirven para proteger ciertos nodos de ciertos pods 
  - Afinidad                    Desarrollo / Negocio
    Sirven para requisitos de negocio con respecto al despliegue:
    - Si la app requiere GPU... y por ende, necesito un nodo con GPU
    - Que kubernetes no me ponga todas las réplicas de mi app en un único nodo... o  en pocos... que las distribuya lo más posible.
    Hay 3 tipos:     
    - Afinidad a nodos
    - Afinidad a pod
    - Antiafinidad de pods

---

# Monitorización de los trabajos (Logs, control del estado de los pods, pruebas)

Por defecto, qué miran los gestores de contenedores con respecto a un contenedor... para saber su estado?
Si el proceso principal (el del command configurado en la imagen del contenedor) está corriendo o no.
Y caso que no, para saber si acabó bien o mal? El código de salida del proceso.

Esto kubernetes lo hereda... también lo hace.

Pero... kubernetes trabaja a nivel de pod.
Y un pod en kubernetes puede estar en qué estados?
- ContainerCreating      Una vez el scheduler decide en qué nodo se ejecuta el pod, se crean sus contenedores
- Initializing           Los contenedores comienzan a arrancar... hasta llegar a un estado de "Arrancado"
- Running                = Arrancado
  - Ready                Si está listo para recibir peticiones de los clientes...
                         Si si está ready, kubernetes LO AÑADE A BALANCEO (al service asociado)
                         Si no está ready, pero si running: LO QUITA DE BALANCEO
                         Si no está running? Depende....De si tiene containers o solo tiene initContainers
                         - Si un pod tiene containers...y sus procesos han acabado (bien o mal)... no están running? O REINICIA !
                         - Si un pod no tiene containers... solo tiene initContainers: Depende del código de salida, lo marca como Completed o Error
                           Esto es menos habitual. Si tengo un pod con solo init containers... coño, mejor usa un job!
- Completed              Jobs o Pods con solo initContainers.

Esto son estado normales de funcionamiento. Luego hay estados de error:
- CrashLoopBackOff       El contenedor ha fallado varias veces al arrancar y Kubernetes lo está reiniciando.
- CreateContainerConfigError          No se encuentra un ConfigMap o un Secret
- ErrImagePull           No encuentro la imagen o hay un error en la descarga
- ImagePullBackOff       Se ha intentado descargar la imagen pero ha fallado.


Toda la gestión más avanzada de estados, kubernetes la realiza mediante las pruebas (PROBES):
- Startup
- Liveness
- Readiness

Al final, cada prueba es:
- Una periodicidad
- Un delay
- Un timeout
- Una operación que debe realizarse: llamada HTTP, chequeo de un puerto, ejecución de un comando.
- Número de éxitos o fallos seguidos para tomar decisión

---

ElasticSearch... guarda datos... y los guarda replicados en un cluster... en nodos de datos.

    Data1
        dato_a
    Data2
        dato_a
    Data3

Y quiero guardar el Dato a... y digo que ese dato va en el INDICE A... y a ese índice le he configurado una redundancia de x2.

En este estado, el nodo Data2, se va de baretas (OFFLINE). Que hace ElasticSearch?

Claro... esto se complica al poner el ES en kubernetes. Porque Kubernetes, al caerse el Data2... que es lo primero que intenta? Reiniciarlo (Crear un pod nuevo en otro sitio).
Qué mecanismo entra antes a funcionar? El que kubernetes decida mover un nodo o el que elasticsearch decida replicar los datos en otro nodo?
Tengo que estar fino!

---

# Logs de un contenedor

Salida estándar y salida de error (AMBAS JUNTAS) del proceso principal que corre en un contenedor.
Y Kubernetes lo guarda... de hecho lo guarda el gestor de contenedores.
Me vale eso? Es insuficiente.
- Los logs los iré perdiendo.
- Cuantos pods tendré en mi cluster? Ciento y la madre! Que hago, voy mirando por ahí log a log... a ver si hay algo.

Necesitamos un sistema de log centralizado: ElasticSearch
Me voy llevando los logs de cada contenedor a ES, y puedo consultarlos con Kibana

# Métricas

- Uso de CPU / RAM
- Número de peticiones realizadas por segundo a mi Servidor de aplicaciones 
- Tamaño de la cola de peticiones en un momento dado
- Tiempo medio de procesamiento de peticiones

En un cluster de kubernetes no tenemos nada de esto.
Esas métricas las he de ir recopilando y guardando en algún sitio.
Cuál es un buen sitio donde guardarlas? Prometheus.. y consultarlos posteriormente desde Grafana

LOGS     > ElasticSearch    < Kibana
METRICAS > Prometheus       < Grafana

Casi todos los despliegues preparados para kubernetes (charts de helm) vienen con exportadores de métricas para Prometheus.

---

Recursos hw en los pods: `resources` dentro de un contenedor/pod
- request
- limits
Hay que prestar especial atención a qué recurso HW? RAM
Si configuramos un limit por encima del request, y el programa necesita en un momento dado más ram de la definida por el request, kubernetes se la entrega... pero si en otro momento, un tercer programa requiere esa RAM (y hay que entregarla, por el request definido en este segundo programa) Kubernetes se cruje el pod que esté usando más ram de la cuenta.

---

# "Operadores" de Kubernetes

Operador... alguien que va a hacer operaciones en este caso, dentro de kubernetes, con respecto a una herramienta concreta que estoy montando.
De nuevo estamos hablando del concepto de AUTOMATIZAR TRABAJOS.

Lo usamos para varias cosas:
- Despliegue de apps
- Tareas de mnto de apps
- Tareas de gestión de las apps

Muchos fabricantes de software, además del software, nos dan herramientas que automatizan muchas operaciones de ese software.
Esos programas son configurables.

> Ejemplo: Tengo una BBDD (Postgres)... una tarea típica de administración/operación del postgres será hacer BACKUPS.

Y el operador de postgres lleva dentro un programa que sabe hacer backups, sin necesidad de un humano.
Ahora... ese programa que viene dentro de ese Operador conoce cómo yo quiero hacer los backups?

Yo necesito explicarle (LENGUAJE DECLARATIVO) a ese programa (Dicho de otra forma, configurarlo) cómo quiero que se hagan los backups por parte de ese programa (que viene dentro del operador).
Esas configuraciones las definimos también en OBJETOS DE CONFIGURACION dentro de ficheros YAML con sintaxis compatible con kubernetes.
Esos OBJETOS DE CONFIGURACION que aporta el propio operador: CRDs (Custom Resource Definitions)

---

# ElasticSearch

Cómo se instala un ElasticSearch en Kubernetes?

Kubernetes es quien hará el despliegue en última instancia.
Pero kubernetes para hacer ese trabajo necesita que le expliquemos cómo:
- Deployment
- Statefulset
- ConfigMap
- Secret
- Service
- ...
Al final del camino hay que escribir un archivo YAML de manifiesto con Deployments... Statefulsets, configMaps.. etc.
Ese archivo lo puedo escribir yo = RUINA! Es muy complejo!

Una opción que tengo es pedirle a alguien que escriba esos archivos por mi...
    - Kustomize -> YAML
    - Helm (template de un Chart) > YAML
      Helm, a diferencia de Kustomize, no solo genera archivos de despliegue, sino que gestiona el ciclo de vida de la app:
      - Install
      - Upgrade
      - Rollback
      - Uninstall
    - Pedírselo a un operador -> Genérame y aplica un archivo de manifiesto de kubernetes para mi despliegue
      Es muy potente... mucho más que HELM.

      Helm al fin y al cabo, lo único que hace es crear y aplicar archivos de kubernetes.
      Pero, por ejemplo, el despliegue de una herramienta (o su actualización) puede requerir tareas adicionales:
      - Configure ciertas herramientas
      - Para ciertos servicios
      La complejidad de un despliegue puede no ser representable en archivos de manifiesto... o ser muy compleja de representar en archivos de manifiesto de kubernetes.

      Dentro del operador lo que viene es un PROGRAMA adhoc escrito para ese despliegue: POSTGRES / ELASTICSEARCH

      Cómo se lo pido al operador? Cargando en Kubernetes un CRD, ofrecido por el propio operador.
      El Operador, tendrá un ServiceAccount asociado, con unos roles asignados.
      Entre esos roles estará la posibilidad de:
      - Crear deployments en Kubernetes
      - Realizar PVC
      Pero también:
      - Monitorizar los CRDs

Ese operador en si... es complejo.
Instalar el operador, ya es un mundo:
- Crear deployments... de esos programas
- Crear ServiceAccounts
- Crear Roles
- Crear RoleBindings
- Crear Services
- Dar de alta los CRDs

Muchas veces esos operadores los instalo con HELM.

Uso HELM para instalar un Operador en el cluster.
Eso acaba con mi cluster enriquecido con nuevos CRDs, programas que estará a la escucha de esos CRDs y **operarán** en consecuencia

El despliegue de una app es algo que puedo automatizar con un Operador (y sus CRDs)
Pero hay más tareas: Hacer un backup de mi bbdd (CRDs)


Cada vez aparecen más y más operadores... y los adoramos.

---

ElasticSearch. Me permite desplegar ES
MariaDB, me permite desplegar MariaDB y automatizar algunas operaciones típicas, como la generación de backups.
CertManager, me permite gestionar certificados SSL en automático... que obtengo de proveedores (ISSUERS) que configuro.
    Este operador me da sus propios CRDs:
    - Issuer: Me permite definir un proveedor de certificados: Let's Encrypt
        ^
    - CertificateRequest: Me permite solicitar un certificado.
        v
    - Certificate (tendrá por ejemplo una fecha de expiración)

     $ kubectl get certificate --all-namespaces

        NAME                                      READY   SECRET                                   EXPIRATION-DATE
        example-com-tls                           True    example-com-tls                          10-08-2026
        example-com-tls-2                         True    example-com-tls-2                        12-08-2026

---

Cluster de Kubernetes
-------------------------
WebApp      ProxyReverso <----- Clientes
    <---Ingress---

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    # add an annotation indicating the issuer to use.
    cert-manager.io/cluster-issuer: nameOfClusterIssuer
  name: miReglaDeIngress
  namespace: mi-web-app-1
spec:
  rules:
  - host: miwebapp1.miempresa.com
    http:
      paths:
      - pathType: Prefix
        path: /
        backend:
          service:
            name: miwebapp1
            port:
              number: 80
  tls: # < placing a host in the TLS config will determine what ends up in the cert's subjectAltNames
  - hosts:
    - miwebapp1.miempresa.com
    secretName: mi-certificado # < cert-manager will store the created certificate in this secret.
```

El secreto `mi-certificado` contendrá el certificado TLS que debe presentar nuestro proxy reverso cuando le llegue una petición con nombre: `miwebapp1.miempresa.com`. Pero ahora mismo, en el momento de cargar el ingress (este archivo) ese secreto no existe.
Pero... en este fichero tenemos metida una anotación... en el metadata: `cert-manager.io/cluster-issuer: nameOfClusterIssuer`

Las anotaciones son un espacio (lista) que podemos asociar a cualquier objeto en kubernetes.
Esas anotaciones son usadas por controladores dentro del cluster... para activarse, o realizar ciertas tareas.

En este caso usamos la anotación: `cert-manager.io/cluster-issuer`. Esa anotación la escucha/procesa el controlador de cert-manager.

El controlador de certmanager necesita un service account, que tenga vinculado (bind) un role que le permita hacer un `watch`, `get`de todos los objetos de tipo `Ingress`que se creen en el cluster.


---


PASO 1: Crear un ns: davidd-mariadb
PASO 2: Instalar el operador de mariadb: HELM (values.yaml)
    - CRDs (MariaDB, Backup, ...)
    - Instala su CONTROLADOR (un programa propio).. que hace qué?
      - Escuchar a ver si se crea algún CRD: $ kubectl get MariaDB --watch -n ???
      - Y cuando llega algo? Genera despliegues para ese MariaDB, según venga configurado.

Qué problema puede haber?

helm uninstall mi-operador-mariadb -n minamespace


# COMANDOS DE HELM

helm repo add REPO(nombre que yo quiero)        REPO_URL

helm pull --untar  REPO/CHART

helm install  NOMBRE_DESPLIEGUE   REPO/CHART  -n NAMESPACE  --create-namespace   -f RUTA/values.yaml

helm uninstall NOMBRE_DESPLIEGUE  -n NAMESPACE