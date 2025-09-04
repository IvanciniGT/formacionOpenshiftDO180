# Comunicaciones

## Service:

### Comunicaciones internas

- ClusterIP: 
  Qué es? IP de balanceo de carga + Entrada en DNS de kubernetes
  Para qué sirve? Qué ofrece?
  - Evitar la necesidad de conocer las IPs de los pods.
  - Alta disponibilidad
  - Escalabilidad

### Comunicaciones externas (exponer puertos donde hay apps funcionando):

- NodePort:
  Qué es? ClusterIP + Expone un puerto (por encima del 30000) en CADA NODO DEL HOST que redirige a la IP DE BALANCEO
  Para qué sirve?
  - La posibilidad de que externamente al cluster se pueda acceder a aplicaciones que están corriendo y enganchadas a la red virtual interna al cluster (que es de la que se saca esa IP DE BALANCEO)
- LoadBalancer: 
  Qué es? NodePort + Gestión automatizada de un balanceador de carga externo (que balancee entre los nodos del cluster) 
  Para qué vale?
  - Evitarme la gestión manual de ese balanceador de carga externo
  - Completar la HA cuando accedo desde fuera del cluster

## Ingress Controller

Son 2 cosas:
- Un proxy reverso
- Un programa que aplica reglas Ingress sobre ese proxy reverso

## Ingress

REGLA DE CONFIGURACION de un proxy reverso que tengo instalado dentro del cluster ... y que es el UNICO ACCESIBLE DESDE FUERA DEL CLUSTER (El que configuro como servicio LoadBalancer)

---

# Volúmenes

Hay 3 tipos de volúmenes, orientados a los 3 grandes usos de los volúmenes:
- Persistir la información tras la eliminación del contenedor       NFS, ISCSI, GlusterFS, CephFS, Cloud (EBS, GCE Persistent Disk, Azure Disk).....
- Compartir información entre contenedores                          EmptyDir
- Inyectar ficheros, carpetas al contenedor                         ConfigMap, Secret, HostPath

## Pero... en caso de persistencia...

Kubernetes nos ofrece una estrategia especial:
- PV  : Persistent Volume         : Operaciones
        - La declaración (el registro) que hacemos en kubernetes de un VOLUMEN FÍSICO que hemos creado externamente al cluster  
- PVC : Persistent Volume Claim   : Negocio/desarrollo
        Es una petición de volumen persistente... con la información (en lenguaje) de negocio: 
        - Quiero un volumen rapidito, encriptado, redundante, de 50Gbs 

El que hace match entre PV y PVC es Kubernetes.
Hoy en día, los operadores no están creando manualmente volúmenes... delegamos ese trabajo a un provisionador de volúmenes.

---

# Cómo influir en el scheduler para que despliegue los pods con un poco más de control

Afinidades:                     Son utilidades que usa NEGOCIO para establecer sus necesidades o preferencias
 - Afinidad con Nodo
 - Afinidad con Pod
 - Anti Afinidad con Pod

Tolerancias/Tintes:             Son utilidades que usa OPERACIONES para proteger los nodos... poder establecer limitaciones respecto a los pods que están permitidos en un determinado nodo-
- Operaciones aplica tintes a los nodos
- En paralelo, desarrollo debe incluir TOLERANCIAS a esos tintes a la hora de definir sus pods.

---

# Monitorización... y Alta disponibilidad

## Contenedores

> Como sabe, el gestor de contenedores, si un contenedor está funcionando y vivo o no?

El gestor de contenedores lo que mira es el PROCESO a nivel de SO, que se abre cuando se arranca el contenedor (COMMAND).
Mientras el proceso siga corriendo, el gestor de contenedores considera que el contenedor esta OK... RUNNING!
Si el proceso acaba, dependiendo del código de salida de ese proceso:
0  .... FINISHED!
>0 .... ERROR!

Esto es lo que hace el gestor de contenedores. NADA MAS.

## El hecho de que un proceso esté corriendo implica que el sistema está en estado saludable? 

NO!

Esa monitorización básica, no es suficiente... ni remotamente suficiente!

DOCKER TIENE UNA COSA que se puede definir en los contenedores: HealthCheck.
Básicamente es un comando, que podemos definir que se ejecute con cierta periodicidad dentro del contenedor. 
Docker ejecuta ese comando.. con esa periodicidad. Y mira su código de salida:
0 = HEALTHY
>0 = UNHEALTHY (Según lo tenga configurado, puedo pedir que si pasa a estado no saludable se reinicie en automático)

NO ES SUFICIENTE ! Ni de lejos!

Kubernetes extiende este concepto: PROBES... Y define 3 tipos de probes, que podemos configurar a nivel de contenedor. A cada contenedor de cada pod podemos irle configurando Probes:
- Startup Probe: Se utiliza para determinar si una aplicación ha iniciado correctamente.
- Liveness Probe: Se utiliza para determinar si una aplicación sigue viva.
- Readiness Probe: Se utiliza para determinar si una aplicación está lista para recibir peticiones.

Lo primero que hace kubernetes al arrancar un pod, es comenzar a ejecutar sobre todos sus contenedores las startup probes. Si esas pruebas no se superan... kubernetes: REINICIA EL POD INMEDIATAMENTE. y si lo tiene que reiniciar 7896 veces... lo hace! mientras siga fallando la prueba, lo hace! lo reinicia!

Una vez que esas pruebas se ha superado, comienza con lasa pruebas de vida... mira a ver si sigue vivo en estado saludable? Si estas pruebas fallan, kubernetes: REINICIA EL POD INMEDIATAMENTE. y si lo tiene que reiniciar 7896 veces... lo hace! mientras siga fallando la prueba, lo hace! lo reinicia!

En paralelo con las pruebas de vida, comienza a hacer las pruebas de readiness. Mira a ver si el proceso (los procesos de los contenedores del pod) está listo para atender peticiones.
Y si estas pruebas fallan? kubernetes LO SACA DE BALANCEO ! Lo quita del service asociado.
Solo permanece o se añade al service cuando/mientras sus pruebas de readiness sean satisfactorias.


Imaginad una BBDD... gorda...

Cuánto tiempo puede tardar en arrancar? 30 min.
Y no ss solo que sea muy gorda... Quizás, en este arranque hemos metido una actualización de versión... y la BBDD debe recrear todos los archivos de la misma.
Quiero que el proceso se reinicie a los 3 minutos? si aún no contesta? NI DE COÑA!... le tengo que dar tiempo.

Ahora bien... ya acabó ese proceso... y ya arrancó!
A la prueba que haré ahora... a partir de este momento, le voy a dar tanto cuartelillo? Voy a esperar 30 minutos a ver si falla o no? Ni de coña... Si la BBDD lleva 1-2 minutos sin contestar: HOUSTON, tenemos un problema!
La configuración de esta prueba debe ser diferente.

La BBDD sigue viva. Está lista para prestar servicio? Este es otro concepto.
Imaginad este escenario:
La BBDD arrancó, está en funcionamiento... pero... se mete en modo mantenimiento para hacer un backup.
Está viva? SI... y puede estar 15 minutos haciendo backup... Y Está VIVA... y saludable... Quiero reiniciarla por que no conteste? NI DE COÑA!

Ahora, está lista para atender peticiones de los usuarios? NO... fuera de balanceo... que no reciba peticiones.
---

# Qué es el log de un contenedor?

La salida estándar y de error del proceso que se ejecuta al iniciar el contenedor (COMMAND).

De hecho, los procesos que corren en un contenedor corren en PRIMER PLANO... no en segundo plano.

---

# Para qué sirven los contenedores?

Para poder ejecutar PROCESOS (SOFTWARE) en un entorno aislado... por las ventajas que ofrece tener ese entorno aislado.

Qué pasa si tengo un contenedor con un script?... o que ejecuta un comando? Y el contenedor acaba?

Si soy docker? o containerd o podman, o crio... es decir, si soy un gestor de contenedores, qué pasa? NADA
Y si soy kubernetes? LA COSA CAMBIA MUCHO!

Y depende de donde esté definido ese contenedor... y resulta que en kubernetes hay muchos varios sitios donde definir un contenedor. Y hasta ahora solo hemos visto 1: Dentro del pod, en el apartado spec.containers

Y Kubernetes entiende que TODOS LOS CONTENEDORES QUE YO DEFINA AHI contienen SERVICIOS o DEMONIOS.
Por ende, entiende que deben estar funcionando 24x7... NUNCA JAMAS BAJO NINGUN CONCEPTO PUEDEN ACABAR... Si acaban, aunque sea con exitcode 0, para kubernetes es una catástrofe. ENTRA EN PANICO... Se desquicia! Y EMPIEZA A REINICIARLOS.

NUNCA PUEDO METER UN SCRIPT o un COMANDO dentro de un contenedor de un pod... al menos en su spec.containers.

Y qué pasa si quiero ejecutar un script o un comando?
- Backup
- Migración de una app... de una versión a otra...
- Si quiero ejecutar un proceso batch (ETL por las noches... que saque datos de una BBDD y los lleve a otra)
- Si quiero que cada vez que arranque un pod, se revise si hay una actualización disponible

^^^
Os parecen casos raros? poco habituales? NO

Alternativas:
- Dentro de un pod, podemos definir initContainers
- Los JOBs


## InitContainers

Es una lista de contenedores que se ejecutan antes de los contenedores principales de un pod.
Se definen dentro de spec.initContainers. Y es una lista ORDENADA.
Kubernetes empieza a ejecutar el primero de esa lista. Cuando acaba, si acaba con código 0, pasa al siguiente... y así sucesivamente. Si alguno falla (acaba con código >0), el pod es reiniciado.
Cuando todos y cada uno de ellos han acabado de ejecutarse, es cuando kubernetes lanza, en PARALELO, la ejecución de todos los spec.containers.

KUBERNETES ASUME que todos los procesos que se lanzan en los init containers son SCRIPTS o COMANDOS... es decir, que acaban...Si se me ocurre poner un proceso que no acabe (un demonio, un servicio... o algo que tarde más de la cuenta - se puede definir un timeout-) KUBERNETES SE DESQUICIA! SE VUELVE LOCO... Y empieza a REINICIAR el pod.

El comportamiento de los spec.initContainers es el OPUESTO a los spec.containers.

Casos de uso?
- Mirar si hay una actualización del sistema antes de ejecutarlo
- Establecer configuraciones...
  - Crear un EmptyDir
  - El primero al que se le monta es al initContainer... que rellena ese volumen con archivos que saca de donde sea... GIT... VAULT
  - Posteriormente cuando ese trabajo está hecho, arranca el container (PRINCIPAL)... y a él también se le monta ese volumen... pero ya viene relleno.
- Asegurar las condiciones necesarios para la ejecución de los containers.
  - Voy a montar mi wordpress.. pero antes de que arranque el apache, necesito que haya arrancado la BBDD.
  - Monto en el pod del wordpress un initContainer... que simplemente intente hacer un query simplón al mariadb... SELECT 1... y lo hace en bucle... Cuando conteste, para... con código de salida 0... Mientras no conteste sigue... con un delay de 5 segundos.
  - Al init container le configuro un timeout... 10 minutos.

Me serviría esto para un backup? Bueno... sería matar moscas a cañonazos.
Los pods existen como concepto para ejecutar SERVICIOS/DEMONIOS...
Kubernetes me permite crear un pod que solo tenga init Containers... pero no tiene mucho sentido.
Si solo quiero algo donde poder ejecutar scripts/comandos, kubernetes tiene otra cosa... otro objeto que puedo configurar.. adhoc para esto: JOBS


## JOBS

Un job es como un pod, en el que kubernetes asume, da por hecho que los contenedores ejecutan procesos que terminan... y cuando lo hacen no los reinicia! Lo malo es que no acabasen... entonces es cuando se desquicia! Reejecuta el job.

Ahora bien... Cuántos Jobs pensáis que vamos a crear en un cluster de kubernetes? En general POCOS... alguno... para una migración puntual, por ejemplo.

Pero en muchas ocasiones, lo que queremos es ejecutar trabajos con cierta periodicidad... por ejemplo, un backup diario/semanal.... una etl, a las 12 de la noche los sábados.

Y no voy a estar todas las semanas/días creando jobs. Le pido a kubernetes que lo haga él. Y en este caso, en lugar de definir un Job, definiré una plantilla de JOB.
El objeto que tiene kubernetes para definir esas plantillas de job: CronJob

CRONJOB: Plantilla de JOB + Programación de su ejecución

---

# Hay muchos tipos de software!

Sistema operativo
Aplicación                  Cuando acaba? NUNCA!
Demonio                     Cuando acaba? NUNCA!
    Servicio
Script                      Cuando acaba? Cuando termina!
Comando                     Cuando acaba? Cuando termina!
Driver
Librería

---

# Tengo un wordpress

Y tengo 4 apaches... en balanceo.

Y... estamos en el día tonto... el día que hay que hacer un upgrade! Hay que actualizar los apaches.
Cómo se hace eso? Paro los 4? Y los actualizo y luego los arranco?
- Es una opción..., en la que desde luego, tengo un tiempo de indisponibilidad del servicio.
- Otra opción es tumbar 2, y actualizarlos... y después arrancarlos... y esperar a que estén READY (listos)
- Y una vez estén ready, quito los otros 2 de balanceo y meto estos 2 nuevos..
- Y ya actualizo(creo nuevos) los tyros 2 .. y a balanceo!

Este tipo de cosas es lo que en kubernetes definimos en PodDisruptionBudgets

---

# Puedo acceder desde un pod de un namespace X a un servicio de un namespace Y?

Si... lo hemos visto antes.

La pregunta no es esa... la pregunta es DEBO PODER? Y seguramente la respuesta aquí sea NI DE COÑA!

Y esto en un entorno de producción TRADICIONAL (Sin kubernetes) lo configuramos mediante? Un firewall... al que le configuramos reglas.

Y eso existe igual en kubernetes! (olvidate de ver esto en docker)
Y en kubernetes tenemos el NetworkPolicy... que no vemos en este curso.. lo vemos en el siguiente.


Los nombres que kubernetes da a las replicas de los pods de un statefulset NO SON ALEATORIOS... son secuenciales:
- mariadb-0
- mariadb-1
- mariadb-2
- mariadb-3
---

Pero es más complejo aún.

---

> Ejemplo 2: Cluster de ElasticSearch

Cada nodo del cluster tiene una función diferente al resto: Es un sistema distribuido

    Maestro1        Maestro2*           Maestro3
        \              |                  /
        BALANCEO: Service:       es-master


    Data1           Coordinador1.       ML1           Ingesta1
    Data2           Coordinador2.       ML2           Ingesta2


Esos nodos han de montar un cluster.
Para montar el cluster, antiguamente ES usaba una comunicación MULTICAST.
Eso daba lugar a un montón de problemas en los clusters.
Esto lo cambiaron hace mucho... y hoy en día la comunicación de formación de clusters se realiza mediante un protocolo unicast.

A cada nodo, al arrancar le digo a que IPS(Nodos) concretos debe buscar... para solicitar AMISTAD.
La gracia es que no tengo que presentar yo cada nodo a todos los demás.
Ellos, en cuanto conocen a alguien nuevo, ya le presentan al resto de amiguitos que conoceran a priori.

Al nodo Data2, por ejemplo, a quién le pido que busque?

Data2 -> es-master
Data1 -> es-master
Coordinador1 -> es-master
Coordinador2 -> es-master
ML2 -> es-master

...

Y al master1? que le pongo? es-master? De hecho no... porque podría ir a él mismo!
Explicitamente, al maestro1 le tengo que pedir que vaya al maestro2 y al maestro3 por ejemplo
Al maestro2 que vaya al maestro3
Y al maestro3 no me hace falta decirle nada.

Pero para poder hacer eso... necesito en la propiedad de marras del ES:
configurar la dirección del maestro2 y del maestro3... le pongo en el fichero de configuración del es del maestro1 las IPS del maestro2 y del maestro3? Me vale eso? A priori, ni conozco las IPs... y además pueden cambiar... ESTO ES RUINA!

Entonces? Tengo que apuntar a un nombre... que identifique UNIVOCAMENTE al MAESTRO2 y otro al MAESTRO3
Esto es OTRA COSA que me regalan los STATEFULSET.
Un statefulset crea varias replicas, pero entiende que son diferentes entre si... que cada una es UNICA.
Y una de las cosas que hace un statefulset es configurar a nivel de dns entradas para cada replica, que las identifiquen univocamente.

En este ejemplo, tendría un servicio generico (CLUSTERIP) para todos los maestros: es-master
Pero el statefulset me cualifica ese nombre (DNS) con subdominios:
- es-master-0.es-master
- es-master-1.es-master
- es-master-2.es-master