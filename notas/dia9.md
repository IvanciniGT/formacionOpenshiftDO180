
# Ampliación del cluster

Requisitos previos:
- Swap desactivado en todos los nodos
- Instalar un gestor de contenedores compatible con Kubernetes
- Puertos abiertos para comunicaciones entre nodos
Instalar: kubelet, kubeadm y kubectl
Unir el nodo al cluster
- En un maestro ejecutamos kubeadm token create --print-join-command
- Ese nos da como salida el comando que ejecutamos en el nodo que queremos unir al cluster

# Montar un ingressController

## IngressController

- Proxy Reverso
- Programa que traduce los recursos Ingress que se crean en el cluster y que deben ser gestionados por este ingressController a la sintaxis especifica del proxy reverso que estemos usando (NGINX, HAProxy, Traefik...)


Cómo se hace en kubernetes la vinculación entre un ingress y un ingressController?
Aquí sale el concepto de IngressClass.
- Al instalar un ingressController, se le asocia un ingressClass
- Al crear un recurso Ingress, podemos decirle a qué ingressClass queremos que se asocie.
  Antiguamente esto se hacía mediante una anotación
  Hoy en día hay un campo para ello: spec.ingressClassName

Qué datos básicos son los que establecemos en el ingress?
- host (path?)
- servicio (nombre del service) + puerto
- si deseamos trabajar con TLS (ofrecemos el nombre del secreto que guarda la clave y el certificado)

Es posible dar reglas de configuración más avanzadas al proxy reverso?
- Lo podemos hacer con anotaciones... pero son específicas del ingressController concreto que usemos. incluso algunas me obligan a usar sintaxis concreta del proxy reverso que viene dentro.

Cuántos ingressController instalamos en un cluster?
Puede ser que necesitemos varios ingressController en un cluster. Dependiendo de factores como:
- Separar servicios por redes de acceso (pública, privada, gestión...)
- Aplicar políticas de calidad de servicio diferentes (limitar anchos de banda...)
- Usar diferentes proxies reversos (NGINX, HAProxy, Traefik...)

# Operadores

Programa que nos ayuda a automatizar tareas de administración, operación y gestión dentro del cluster:
- Gestión de certificados
- Despliegue de aplicaciones complejas
- Gestión de backups
- Crear usuarios dentro de un sistema

Cómo le damos instrucciones a estos programas? Mediante CRDs (Custom Resource Definitions)

# CRDs??

Un CRD es un esquema YAML para definir un nuevo tipo de objeto/recurso dentro de Kubernetes.
Me dice que estructura de datos (claves,m tipos de valores) he de usar para definir un nuevo tipo de objeto en el cluster.
Por ejemplo, si quiero poder definir un usuario para Keycloak, me podría servir algo como:

```yaml
apiVersion: keycloak.org/v1alpha1
kind: KeycloakUser
metadata:
  name: my-user
spec:
  realm: my-realm
  username: my-username
  email: my-email@example.com
  firstName: My
  lastName: User
  enabled: true
  credentials:
    - type: password
      value: my-password
      temporary: false
---
```
El CRD es la especificación de la estructura de ese archivo:
Para un usuario, en su spec , es necesario:
- realm, que debe contener un string
- username, que debe contener un string
- email, que debe contener un string
- firstName, que debe contener un string, pero que es opcional
- lastName, que debe contener un string, pero que es opcional

ESO ES UN CRD.

La primera operación que necesito hacer antes de instalar un operador es cargar en el cluster todas las nuevas definiciones de objetos (CRDs) que ese operador va a usar.

Yo después cargaré objetos de esos nuevos tipos (CRDs) .

$ kubectl apply -f miFicheroQueContieneCRs.yaml

Y cuando hago eso que pasa?
- En principio ese comando lo que hace es guardar esos objetos nuevos en la bbdd de kubernetes : ETCD
- El operador (un pod que hay dentro... que se suele llamar controller) está monitorizando mediante el API de kubernetes si se crean CRDs de los tipos que él gestiona.
- Cuando detecta que se ha creado un objeto de un tipo que él gestiona, lee ese objeto y actúa en consecuencia (crea pods, servicios, volúmenes... ejecutará funciones suyas propias....lo que sea)

# KeyCloak

IAM (Identity and Access Management)
Keycloak me permite gestionar usuarios, roles, permisos de acceso a aplicaciones web.
Puede usar su propia BBDD de usuarios o integrarse con directorios LDAP, incluso delegar la autenticación en otros sistemas (Google, Facebook, Microsoft, Github...)
Me ofrece politicas avanzadas de alta de usuarios, gestión de contraseñas, autenticación en dos factores, Single Sign On (SSO)...

Esta herramienta tiene un operador disponible para Kubernetes:
- Desplegar una instancia de Keycloak
- Gestionar Realms (conjunto de usuarios, roles, aplicaciones...)
- Crear usuario (YAML), asignarle roles
- Dar de alta aplicaciones (clientes) que van a usar Keycloak para autenticar usuarios


Necesito desplegar un microservicio:
- Que use OAuth2 para autenticar a los clientes del microservicio
- Necesito disponer de un Identity Provider (IdP) que gestione los usuarios y la autenticación
- Necesito registrar en esa herramienta (IdP) el microservicio como una aplicación que va a usar ese IdP para autenticar a sus usuarios
- JAVA+SpringBoot
- BBDD: Postgres
- Caches: Redis

---

# ElasticSearch

- Instalar operador Elastic Cloud for Kubernetes
- Crear un cluster de ElasticSearch de 1 nodo... sorpresita que nos llevamos???
  - ElasticSearch necesita configuraciones especiales a nivel de kernel de linux...
  - Esas configuraciones hay que hacerlas a nivel del host!
  - Por defecto un contenedor no puede modificar parámetros del kernel del host
  - Si hay formas de hacerlo: Con contenedores Privilegiados:
      - securityContext:
          privileged: true
          runAsUser: 0
    En el caso de ElasticSearch, podíamos hacerlo en un initContainer, que se ejecute antes de que arranque el contenedor principal. Otra opción que nos ofrecían era el usar un DaemonSet (un pod que se ejecuta en todos los nodos del cluster) y que ese pod fuera privilegiado y ejecutara el comando sysctl -w vm.max_map_count=262144
      
  - Por qué esas 2 opciones? Siempre que hay 2 opciones... en general... es que ambas tienen sus cosillas.
  
    - initcontainer
      - GUAY:   Me aseguro que el Elastic no arranca hasta que el parametro ha sido establecido
                Además ese trabajo se hace siempre antes de arrancar el ElasticSearch... lo cuál me garantiza que aunque se haga un despliegue en una nueva máquina del cluster, el parámetro se establecerá antes de que arranque el ElasticSearch
                Ese trabajo, se ejecuta... y punto pelota!        
                LO CREA NEGOCIO... sin depender de nadie
      - RUINA:  El problema es que la persona que despliegue el ES posiblemente (casi con total seguridad) no va a tener permisos para ejecutar contenedores privilegiados.
  
    - daemonset
      - GUAY:   El daemonset se ejecuta en todos los nodos del cluster... y si yo añado nuevos nodos al cluster, el daemonset se ejecutará también en esos nuevos nodos.
                El daemonset lo puede desplegar un administrador del cluster (que si tiene privilegios especiales)
      - RUINA:  No hay garantía de que el daemonset se ejecute antes de que arranque el ElasticSearch... aunque podemos controlarlo metiendo un initcontainer dentro del ES que espera a que el parámetro esté establecido.
                El daemonset se queda ahí corriendo... haciendo nada... hasta que yo lo borre.
                NEGOCIO YA NO PUEDE HACER EL EL TRABAJO.. depende de que el administrador del cluster haya desplegado el daemonset.
                
En nuestro caso, planteamos otras opciones:
- Playbook de Ansible que se ejecute en los nodos del cluster y que establezca el parámetro.
      - RUINA?     Asegurar que ese playbook se ejecute en todos los nodos del cluster (nodos actuales y FUTUROS??)
                  - En autoescalados con sistemas automatizados (Openshift, Rancher...) no hay garantía de que el playbook se ejecute en los nuevos nodos. Nos toca... programar algunas cositas adicionales.
                  NEGOCIO YA NO PUEDE HACER EL EL TRABAJO.. depende de que el administrador del cluster haya creado/ejecutado/programado el playbook.
                  Y eso puede introducir demoras de tiempo.


---

- Usar ese ingressController (crear alguna regla de ingress)
- ResourceQuota y LimitRange
- NetworkPolicy
- PodDisruptionBudget
- HPA

---

# ResourceQuota y LimitRange

Son 2 objetos que son gestionados por administradores del cluster... es más, debo asegurarme que los ServiceAccount que suministre a un equipo de trabajado no puedan modificar ni eliminar ni crear esos objetos. Que puedan verlos.

Ambos objetos se utilizan para limitar lo que un equipo puede hacer dentro de un namespace.

El primero que nos tenemos que asegurar de establecer es el ResourceQuota. El limitRange es más avanzado... es para un segundo nivel de control más fino.

El control gordo lo hago con ResourceQuota.

Con este objeto lo que limitamos es TOTALES:

- Total de CPU que pueden consumir todos los pods del namespace
- Total de memoria que pueden consumir todos los pods del namespace
- Total de cantidad de almacenamiento que pueden consumir todos los volúmenes persistentes (PVC) del namespace
  Incluso limitado por clases de almacenamiento (storageClass) 

Además de recursos físicos del cluster, también limitan número(cantidad) de objetos que se pueden crear en el namespace:
- Número máximo de pods
- Número máximo de servicios
- Número máximo de volúmenes persistentes (PVC)
- Número máximo de secretos
- ....


```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: disable-cross-namespace-affinity
  namespace: foo-ns
spec:
  hard:
    limits.cpu:         "8"
    limits.memory:      "10Gi"
    requests.cpu:       "2"
    requests.memory:    "8Gi"
    requests.storage:   50Gi
    persistentVolumeClaims:     10
    rapidito-redundante.storageclass.storage.k8s.io/requests.storage:  20Gi
    rapidito-redundante.storageclass.storage.k8s.io/persistentVolumeClaims:  5
    requests.ephemeral-storage:  8Gi    # A nivel del host
    limits.ephemeral-storage:    10Gi 
```

limit.cpu: Entre todos los limits de cpu de todos los contenedores de todos los pods del namespace no pueden superar 8 CPUs

requests.memory: Entre todos los requests de memoria de todos los contenedores de todos los pods del namespace no pueden superar 8Gi


TODO CLUSTER tiene establecidos unos limits y requests máximos por defecto para los pods que se ejecutan en el cluster. Eso lo hacemos con los LimitRange.

# Los limit range nos permiten un control más fino.

No es que limitemos los recursos a nivel global... sino que los limito a nivel de pod o de contenedor.

```yaml
apiVersion: v1
kind: LimitRange
metadata:
    name: limits
    namespace: foo-ns
spec:
    limits:
      - default:                            # Default limit
          cpu: 500m
          memory: 5Gi
        defaultRequest:                     # Default request
          cpu: 250m
          memory: 512Mi
        max:                            # Max limit
          cpu: 1
          memory: 4Gi
        min:                            # Min limit
            cpu: 100m
            memory: 256Mi
        type: Container
```

El objetivo de los limit range principal es que no me generan pods demasiado grandes al trabajar. El problema con un pod muy grande es que cuesta encajarlo dentro de los hosts... y además una vez encajado me comen mucha capacidad de ese host... y me da poco juego para encajar otros pods.


---

ElasticSearch - Motor de indexación (Me sirve para montar mi propio GOOGLE en la empresa)
 INDICE - Agrupación lógica de documentos. LOS LOGS DE LOS APACHES DEL MES DE ENERO del 2025
   Internamente estos INDICES se guardan en lo que se llaman SHARDS (Fragmentos)
   Cada fragmento se gestiona por separado (Apache LUCENE)


Indice Apaches: F1, F2, F3

Nodo1
    F1, F2'
Nodo2
    F2, F1', F3'
Nodo3
    F3

Yo decido cuántos fragmentos quiero tener en un índice. Más fragmentos me permiten paralelizar más las búsquedas... pero también me generan más sobrecarga de gestión.

En los fragmentos se guardan índices inversos/invertidos (LUCENE). Esto nos permite hacer búsquedas fulltext muy rápidas.

    > OutOfMemoryError: Java heap space... El servidor 192.178.0.31 ha explotado y es necesario reiniciarlo
     ^^^ID: 192837

    Búsqueda: "explotado" y "java"

    Índice inverso:
        outofmemoryerror: [ID: 192837, posición: 1]
                          [ID: 182736, posición: 5]
        java: [ID: 192837, posición: 2]
              [ID: 182736, posición: 3]
              [ID: 182737, posición: 8]
        heap: [ID: 192837, posición: 3]
        space: [ID: 192837, posición: 4]
        servidor: [ID: 192837, posición: 6]
        192.178.0.31: [ID: 192837, posición: 7]
        explotado: [ID: 192837, posición: 9]
        necesario: [ID: 192837, posición: 10]
        reiniciarlo:    [ID: 192837, posición: 11]
                        [ID: 192837, posición: 11]
                        [ID: 192837, posición: 11]
                        [ID: 192837, posición: 11]

Cuanto más grande sea un fragmento, más RAM necesita. Esa estructura de datos se guarda en ficheros.. pero cuando pido una búsqueda en ES necesito que esos ficheros estén en RAM.

> Pregunta: A nivel de RAM: Me interesa más tener 3 fragmentos o 1 sólo?
     Si tengo 1 millón de entradas, qué será más óptimo: Guardarlas en 1 fragmento o repartirlas en 3 o da igual?
     A nivel de "RAM" lo más óptimo es tener 1 único fragmento.
     Si solo tengo en cuenta almacenamiento, lo más óptimo es tener 1 solo fragmento.

     En el índice tengo 2 partes:
        términos (palabras que aparecen en los documentos)
        ubicaciones (dónde aparecen esos términos en los documentos)
     Si juntos todos los datos en un fragmento, cuántas veces tengo que guardar cada TÉRMINO? 1

---

F1
        outofmemoryerror: [ID: 182736, posición: 5]
        java: [ID: 182736, posición: 3]
              [ID: 182737, posición: 8]
        heap: [ID: 192837, posición: 3]
        space: [ID: 192837, posición: 4]
        servidor: [ID: 192837, posición: 6]
        192.178.0.31: [ID: 192837, posición: 7]
        explotado: [ID: 192837, posición: 9]
        necesario: [ID: 192837, posición: 10]
        reiniciarlo:    [ID: 192837, posición: 11]
                        [ID: 192837, posición: 11]

F2
      outofmemoryerror: [ID: 182736, posición: 5]
      java: [ID: 192837, posición: 2]
      reiniciarlo:    [ID: 192837, posición: 11]
                        [ID: 192837, posición: 11]

Los términos de un índice pueden ocupar un 30-50% del espacio total del índice.
Si empiezo a generar fragmentos, el almacenamiento que necesito para guardar el mismo índice se puede duplicar o triplicar.... y la ram TOTAL que necesite del cluster puede irse al doble.

---

Cluster: 
Nodo1.(84)   etiquetas: nodo1-NOMBRE
Nodo2.(151)  etiquetas: nodo2-NOMBRE

kubectl label node NODO1  nodo-DAVID=nodo1
kubectl label node NODO2  nodo-DAVID=nodo2

Namespace: prueba-DAVID

LimitRange:
    Defaults Container:
        memory: 20Mi

ResourceQuota: 
    request/limit
        memory: 40Mi

Deployment:
 replicas: 1
 pod: 
    initContainer: sleep 1 # sleep 30
            #memory: 5Mi
    nginx
        requests/limits
            memory: 35Mi
    afinidad preferida con nodo2-NOMBRE
        preferredDuringSchedulingIgnoredDuringExecution:


Autoescalador Horizontal de Pods (HPA)
- 2 y 4 en base al uso de cpu. Como no estaremos usando... creará 2

drain del nodo2
uncordon del nodo2
borrar los pods a mano

poddisruptionbudget: 
 minAvailable: 1

drain del nodo2

---

kind:             Namespace
apiVersion:       v1
metadata:
    name:           prueba-ivan
---
apiVersion: v1
kind: LimitRange
metadata:
    name: limits
    namespace: prueba-ivan
spec:
    limits:
      - default:                            # Default limit
          memory: 20Mi
        type: Container
---

apiVersion: v1
kind: ResourceQuota
metadata:
  name: quota-ivan      
  namespace: prueba-ivan

spec:
    hard:   
        requests.memory:      40Mi
        limits.memory:        40Mi

---


kubectl label node ip-172-31-44-84  nodo-ivan=nodo1
kubectl label node ip-172-31-17-151 nodo-ivan=nodo2


---

kind:           HorizontalPodAutoscaler
apiVersion:     autoscaling/v2

metadata:
  name:           hpa-ivan

spec:
    # Qué es lo que vamos a escalar... Suponiendo que tenemos un deployment con un nombre aaaaa
    scaleTargetRef:
        kind:       Deployment
        name:       aaaaa
        apiVersion: apps/v1
    # Mínimo y máximo de réplicas admitidas
    minReplicas: 2
    maxReplicas: 4
    # En base a qué métrica(s) se va a escalar
    metrics:
      - type: Resource
        resource:
          name: cpu                 # memory
          target:
            type: Utilization # Trabaja en Porcentaje
            averageUtilization: 40  # Tendría en cuenta todas las réplicas y si el uso medio de cpu supera el 50% escalaría
      - type: Resource
        resource:
          name: memory                 # memory
          target:
            # A veces queremos trabajar ocn valores absolutos
            type: AverageValue # Trabaja en valores absolutos
            averageValue: 5Mi 
---




> Escenario 1... querría escalar?

Pod1
    60% + 40% -> 100% ---> OFFLINE!
Pod2
    40% OFFLINE

La escalabilidad sirve para Más capacidad de trabajo... pero debe aguantar/ofrecer la HA.


---

kind:                 Deployment
apiVersion:           apps/v1
metadata:
    name:             nginx

spec:
    replicas:         1
    selector:
        matchLabels:
            app:      nginx
    template:
        metadata:
            labels:
                app:  nginx
        spec:
            affinity:
                nodeAffinity:
                  preferredDuringSchedulingIgnoredDuringExecution:
                    - weight: 1
                      preference:
                        matchExpressions:
                          - key: nodo-ivan
                            operator: In
                            values:
                              - nodo2
            initContainers:
              - name: init-sleep
                image: busybox
                command: ['sh', '-c', 'sleep 1']
            containers:
              - name: nginx
                image: nginx
                resources:
                    requests:
                        memory: 35Mi
                    limits:
                        memory: 35Mi

---

kind:                 PodDisruptionBudget
apiVersion:           policy/v1
metadata:
    name:             pdb-ivan

spec:
    minAvailable: 1
    # maxUnavailable: 1
    selector:
        matchLabels:
            app: nginx
---

Todo el tema de podDisruptionBudget tiene sentido cuando tengo más de una réplica.
Si solo tengo una replica:
    minAvailable: 0 <---- Igual que no poner nada.. que no definir pdb.
    minAvailable: 1 <---- Bloqueante... evita hacer drains

Hay 2 formas de sacar los pods de un nodo:
- Drain (administrador del cluster) <--- Este es el que tiene en cuenta los pdbs
- Taint :NoExecute 

---

kind:                Service
apiVersion:          v1
metadata:
    name:              servicio-nginx
spec:
    selector:
        app:           nginx
    ports:
      - protocol:    TCP
        port:        80
        targetPort:  80
    type:            ClusterIP
---

kind:                Ingress
apiVersion:          networking.k8s.io/v1
metadata:
    name:              ingress-nginx

spec:
    ingressClassName:  nginx-ivan
    rules:
      - host:          app.ivan.com
        http:
          paths:
            - path: /
              pathType: Prefix
              backend:
                service:
                  name: servicio-nginx
                  port:
                    number: 80