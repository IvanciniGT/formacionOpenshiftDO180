# Wordpress

Nos sirve para montar páginas web.
Es una app desarrollada en php. Y corre sobre un servidor web:
- Apache : 80
- Nginx
- ...

que ofrezca eso sí, soporte para php.

Además, necesita una BBDD a la que conectar:
- mysql
- mariadb: 3306

La gente que hace wordpress nos ofrece imágenes de contenedor... varias.
En unas viene solo wordpress y php... Son más incómodas para nuestro caso. (-fpm)
En otras, me viene ya: Apache + PHP + Wordpress, to'junto

Por otro lado tiraremos de una imagen de mariadb, oficial. La última DECENTE que podamos poner.

A priori, vamos a montar un pool de wordpresses.. apaches! (cluster... con 2)
- Deployment: Plantilla POD + 2 replicas
  Y al final, todos los pods de apache van a ser iguales entre si.
Y vamos a poner solo un MariaDB (standalone)
- StatefulSet: Plantilla POD + 1 replica
  Y al final, todos los pods de mariadb van a ser iguales entre si.

ESTO FUNCIONARIA.... Pero conceptualmente sería incorrecto.
El mariaDB va a ser un Statefulset
---

Namespace
Deployment del Wordpress
StatefulSet del mariadb
Service Wordpress
Service para el MariaDB
Configmap
Secret
Volumen para Wordpress
Volumen para MariaDB
Petición de Volumen para el Wordpress

---
Horizontal Pod Autoscaler para el Wordpress
NetworkPolicy para el Wordpress y el MariaDB


---

BBDD:
- Cluster activo / activo
- Primario / Replicas (espejos)
- Standalone

Cuál de esas no sirve dentro de un cluster de Kubernetes? TODAS PUEDEN SERVIR para un entorno de producción en kubernetes.

El modo standalone... realmente al llevarlo a kubernetes es un Cluster activo/pasivo.

El almacenamiento, los datos, los tendré a salvo en algún volumen persistente, externo al cluster.
Si tengo un único pod... y se cae... puedo levantar otro que apunte al mismo volumen.
Y ahí siguen los datos.
Es cierto que tendré un tiempo de indisponibilidad. (segundos.... pocos minutos..)
Quizás entre dentro del acuerdo de servicio;: 99,9%, 99,99%

---

Plantillas de pods:
- Deployment:           Plantilla de pod + Nº de réplicas
- DaemonSet:            Plantilla de pod de la que kubernetes genera 1 replica por nodo.
- StatefulSet:          Plantilla de pod + Nº de réplicas + al menos 1 pvc


    MariaDB1  \
     ^v                         Apache1
    MariaDB2  - BALANCEADOR -           --- Balanceador ---  Proxy reverso <---
     ^v                         Apache2
    MariaDB3  /


                Service                      Service
                ClusterIP                   ClusterIP

Tiene que haber volúmenes persistentes?
- Para la BBDD
- También para los Apaches del WP

Respecto a los MariaDBs... cada Pod (cada mariaDB) tiene su propio volumen o lo comparten: 1 cada 1
Para las BBDD necesito 3 volumenes! 3 volumenes IGUALES ENTRE SI (de tamaño, de características.) pero independientes. Cómo pedimos un volumen persistente en kubernetes? PVC.
Por tanto , cuántos pvc debo crear para las mariaDB? 3.
Y si el día de mañana quiero escalar a 5? necesitaré crear 2 pvcs adicionales.

Lo que hacemos es no crear ningún PVC... y le decimos a kubernetes que los cree él.. según necesite...
Desde una plantilla de pvc <--- Esto es una de las cosas que nos permiten los statefulset, que no permiten los deployments

Para los apache... queremos 1 volumen compartido o uno para cada apache? Compartido
Si subo un pdf, ese pdf tiene que estar disponible desde todos los apaches.

Coño... pero si meto un metadato... también tiene que estar disponible en todos los MARIADBs?
El tema está en cómo guarda internamente los datos el apache y las BBDD.
El apache, cada foto, pdf.. lo que sea que yo suba lo guarda como un archivo INDEPENDIENTE!
Puedo tener a la vez 2 apaches TOCANDO EL MISMO ARCHIVO? (No digo leyendo...) digo tocando! NO
De hecho, aunque en 2 apaches simultaneamente alguien subiera el mismo archivo, a nivel de disco se guardan 2 archivos con ¡nombres independientes.

En cambio, una BBDD guarda TODOS LOS DATOS en un único archivo. Podría tener 3 procesos, de 3 mariadbs tocando el mismo archivo en varios sitios distintos simultaneamente? NO

Todos los sistemas de almacenamiento de datos necesitan volumenes independientes en sus replicas.
MariaDB, ElasticSearch, Mongo, Kafka... cada pod, necesita su propio volumen persistente.

En el caso del resto de sistemas, no es así... deben compartir volumenes.

PERO ESTO NO ES EL UNICO MOTIVO.

> Cómo va nombrando Kubernetes a las replicas que hace de un deployment? Una parte del nombre es aleatoria.

Y de hecho, las replicas son reemplazables entre si.... o por una nueva... Son todas idénticas!
Si se muere un apache... me basta con levantar OTRO apache cualquiera... que sea exactamente igual a los anteriores.

Si se muere el pod mariadb1... claro está que he de levantar otro... pero ese otro... será un pod nuevo? será igual que los anteriores? NO.
Tiene que ser una copia IDENTICA del pod mariadb1


Ese pod, tiene su personalidad propia... y es diferente del pod mariadb2 y del pod mariadb3
En este caso, porque tiene datos diferentes.