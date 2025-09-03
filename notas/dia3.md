
# Volúmenes en Contenedores

Punto de montaje en el filesystem del contenedor que apunta a una ubicación fuera del mismo (Cloud, HDD host, cabina... RAM host)

Sirven para:
- Persistir la información tras la eliminación del contenedor
- Compartir información entre contenedores
- Inyectar archivos o carpetas en un contenedor (como por ejemplo, configuraciones)

# Volúmenes en Kubernetes

Kubernetes tiene o maneja también el concepto de Volumen.. pero de una forma un poco diferente.

De entrada, en Kubernetes, los volúmenes se crean/definen a nivel de POD, no a nivel de contenedor.
Posteriormente, podemos montar esos volúmenes en 1 o varios contenedores de ese pod.

Kubernetes tiene muchos tipos de volúmenes... muchos!

Esos tipos de volúmenes tienen usos diferentes:
- Persistir la información tras la eliminación del contenedor                           NFS, ISCSI, AWSVolume, GCP
- Compartir información entre contenedores                                              EmptyDir
- Inyectar archivos o carpetas en un contenedor (como por ejemplo, configuraciones)     ConfigMap, Secret, HostPath

Al usar kubernetes, los volúmenes persistentes NO PUEDEN ESTAR EN LOS HOST!
Necesitamos un sistema de almacenamiento EXTERNO AL CLUSTER... o al menos INDEPENDIENTE DE LOS HOST.
Ya que un pod(contenedores) pueden ser movidos de un host a otro... o un host caerse...
No me puedo fiar de que los datos que guarde en un host estén accesibles en todo momento... no hay alta disponibilidad.


Cuando hablamos de volúmenes persistentes,
- El desarrollador hace su petición
- El operador del cluster, define volúmenes que hay disponibles en un backend

Kubernetes es quien hace MATCH... el Tinder de los volúmenes.


# Qué es un StorageProvider?

Eso es un programa que podemos montar en un cluster de kubernetes / openshift.
Eso lo monta el administrador del cluster.
Puede instalar 1 o 17 storage providers diferentes, dependiendo de las necesidades del cluster.

Un storage provider es un programa que está monitorizando en tiempo real las persistentVolumeClaims (las peticiones) de volumen que los desarrolladores hacen.
Cuando un desarrollador hace una nueva pvc, el storage provider se encarga de:
- Conectar con el backEnd adecuado (AWS, Cabina...) y crea allí automáticamente un VOLUMEN REAL, capaz de satisfacer la petición... Si me piden 1Gb en la pvc, se crea en el backend un volumen de 1Gb.
- Crea en kubernetes la pv... es decir, registra en automático ese volumen recién creado
- Y obliga a Kubernetes a vincular ese volumen a la la pvc que dió lugar a dicho volumen.

Los storage providers tienen asociado un storageClass, UNICO.
Los storage class, a priori, yo puedo poner lo que me de la gana (tanto en pv como en pvc)... Kubernetes lo unico que mira es que coincidan esos valores..
Pero... puedo dar de alta storageclasses de antemano, y vincularlos con UN UNICO storage provider.

De forma que cuando se cree una pvc de un determinado storageClass, será el provider de ese storageClass el que se encargue de satisfacer la petición.

---

# Afinidades                                    Desarrollo

Se definen a nivel de pod (o de plantilla de pod)
Hay 3 tipos:
- Afinidades a nivel de nodo. Quiero decirle a kubernetes que Intente (o lo haga por el artículo 33) que busque una máquina que cumpla con unas características.
  Dentro del pod podemos definirlo con estas sintaxis:
    ```yaml
    nodeName: <nombre-del-nodo> # Aquí perdemos la alta disponibilidad... me la juego a un host
                                # Quizás si tengo un host con una GPU muy especial.. que es necesaria para un programa que tengo.
                                # Lo usamos poco
    # Los nodos pueden tener asociadas ETIQUETAS (LABELS).
    # $ kubectl label nodes <nombre-del-nodo> <etiqueta>=<valor>
    nodeSelector:
        <etiqueta>: <valor>     # Aquí le digo a kubernetes que busque un nodo que tenga esa etiqueta con ese valor
                                # Si no hay ningún nodo con esa etiqueta y valor, el pod se queda en estado PENDING
                                # Lo usamos MUCHO... es bastante potente, y muy sencillo de escribir

    # La más potente de todas... con diferencia.. pero que no usamos tanto, por su complejidad... a no ser que sea estrictamente necesario.
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution: # Reglas obligatorias
          nodeSelectorTerms:
          - matchExpressions: # Y podemos poner varias reglas obligatorias
            - key: <etiqueta>
              operator: In # , NotIn, Exists, DoesNotExist, Gt and Lt
              values:
              - <valor1>
              - <valor2>
              - <valor3>
        preferredDuringSchedulingIgnoredDuringExecution: # Reglas preferidas... que no tienen por que cumplirse... pero son deseables
        - weight: 100 # También podemos poner muchas y darles un peso
          preference: 
            matchExpressions:
            - key: <etiqueta>
              operator: In
              values:
              - <valor>
    ```


- Afinidades a nivel de pod

Con ésta, le indicamos a kubernetes que nos gustaría o que queremos obligatoriamente que nuestro pod se despliegue en un nodo que comparta etiqueta con un nodo que ya tenga un pod determinado(que cumpla con unas características)

Zona geográfica 1
    NODO 1
        apache
    NODO 2
Zona geográfica 2
    NODO 3
    NODO 4

Quiero desplegar un apache... y un mariadb... pero quiero desplegarlos en la misma zona geográfica... me da igual cual... pero en la misma.
Lanzo el apache... y se me monta en la zona 1.
En qué nodos me valdría la BBDD? NODO 1, NODO 2

Lo que quiero aquí es generar afinidad, con los pods de tipo apache... pero no a nivel de nodo... a nivel de zona.
Si un nodo, pertenece a la misma zona que cualquier nodo (incluso el mismo) que tenga un apache, es candidato para recibir el mariadb.

```yaml
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - apache
        topologyKey: zona # esto genera 2 grupos de nodos... o 17 en otros casos... Agrupa nodos que compartan valor de la etiqueta
```

Esto me tocaría a los nodos de la zona 1, ponerles una etiqueta `zona` a ambos con el mismo valor... y diferentes de los nodos de la zona 2:
$ kubectl label nodes nodo1 nodo2 zona=1
$ kubectl label nodes nodo3 nodo4 zona=2

Lo que se busca es si en algún nodo de un grupo determinado.. (se hace para cada grupo esa comprobación) hay un pod que cumple con el criterio, TODOS LOS NODOS de ese grupo son candidatos a recibir el pod.

Hay una etiqueta especial que kubernetes pone a TODOS LOS NODOS de forma AUTOMATICA: `kubernetes.io/hostname`
Si uso esa etiqueta como topologyKey, lo que haría sería agrupar los nodos por su nombre de host. Es decir.. no agrupa un cagao... O hace grupos de 1 nodo... porque cada nodo tiene un valor DIFERENTE de hostname.

- AntiAfinidades a nivel de pod - SE USA SIEMPRE

Con ésta, le indicamos a kubernetes que nos gustaría o que queremos obligatoriamente que nuestro pod NO se despliegue en un nodo  que comparta etiqueta con un nodo que ya tenga un pod determinado (que cumpla con unas características)

    NODO 1
        apache1
    NODO 2
        apache2
    NODO 3
        apache3

Y quiero desplegar mi Wordpress... y parte de ese despliegue es un apache... necesito 3 instancias del apache (escalabilidad)

Suponiendo que cada pod de apache tiene una etiqueta (LABEL) `app: apache`

```yaml
affinity:
  podAntiAffinity:
    #requiredDuringSchedulingIgnoredDuringExecution:
    #  labelSelector:
    #    matchExpressions:
    #    - key: app
    #      operator: In
    #      values:
    #      - apache
    #  topologyKey: kubernetes.io/hostname
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchExpressions:
          - key: app
            operator: In
            values:
            - apache
        topologyKey: kubernetes.io/hostname

```

# Toleraciones/Tintes (Taints / Tolerations)    Operaciones

Las tolerancias y los tintes complementan las afinidades a nivel de nodo.
Mientras que las afinidades a nivel de nodo sirven para que NEGOCIO o DESARROLLO pueda indicar lo que necesita o prefiere, las toleraciones y los tintes sirven para que Operaciones (Administración del cluster) pueda proteger el cluster de un mal uso.

> Un equipo quieres desplegar una app. Y van y meten que quieren que su app se instale en unos nodos con gpus muy potentes... pero no... no les hace falta... O al menos yo no quiero.. porque tengo nodos con gpus muy potentes, pero los tengo reservados para otras apps.

Operaciones del cluster puede teñir una máquina, aplicarle un tinte:

$ kubectl taint nodes <nombre-del-nodo> <etiqueta>=<valor>:<efecto>

Efecto: 
- NoSchedule
- PreferNoSchedule
- NoExecute

Si operaciones pone una etiqueta con un valor usando efecto NoSchedule en un nodo, ningún pod podrá desplegarse en ese nodo, a no ser que... TOLERE ese tinte.

El desarrollador entonces debe incluir en su definición del pod:

```yaml
tolerations:
- key: <etiqueta>
  operator: Equal
  value: <valor>
  effect: NoSchedule
```

El modo NoExecute... es mucho más drástico. Quita (desagua) los pods que no toleren el tinte... aunque ya estén allí corriendo. El caso.  duso de esto es más restrictivo. Se usa para dejar un nodo seco (sin pods) antes de hacerle operaciones de mnto.


---

# Cliente de kubernetes: kubectl

$ kubectl <verbo> <tipo de objeto> <args>

## tipos de objetos:
                            Alias
- namespace(s)              ns
- pod(s)
- node(s)
- deployment(s)
- secret(s)
- configmap(s)
- service(s)                svc
- ingress
- persistentvolumeclaim     pvc
- persistentvolume          pv
- ...

## Verbo, dependiendo del tipo de objeto...
Algunos son comunes y los puedo ejecutar sobre cualquier tipo de objeto:

- delete   
  $ kubectl delete pod <nombre> -n <nombre-namespace>
- describe
  $ kubectl describe pod <nombre> -n <nombre-namespace>
- get (lista todos los que hay)
  $ kubectl get pod -n <nombre-namespace>
  $ kubectl get svc -n <nombre-namespace> 

## args:
 -n --namespace <nombre>
 --all-namespaces



$ kubectl apply  -f <archivo.yaml> -n NAMESPACE
    Crear o Modificar(si es posible) dentro del namespace los recursos que se definen en el fichero
$ kubectl create -f <archivo.yaml> -n NAMESPACE
    Crear en el cluster, dentro del namespace los recursos que se definen en el fichero
$ kubectl delete -f <archivo.yaml> -n NAMESPACE
    Borra del cluster todos los recursos que se definen en el fichero
