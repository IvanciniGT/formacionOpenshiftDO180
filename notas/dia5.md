Wordpress

ServiceAccount

Openshift
Route
Images...

ResourceQuota
LimitRange
NetworkPolicy
PodDisruptionBudget


---


- Recursos CPU / Memoria que se asignan a los PODs <-- Plantilla de Pod
            2      8
                RATIO entre CPU / RAM
- Autoescalado

---

# Bienvenidos a HELM!

En la realidad, al menos para lo que son productos comerciales, no estamos jodiendo escribiendo YAML a mano. 
NO SE HACE... estos ficheros son EXTRAORDINARIAMENTE COMPLICADOS de crear/mantener.
Nuestros ficheros (de este ejemplo del wordpress) son MUY MUY INSUFICIENTES para un entorno de prod.
Están bien, como ejemplo conceptual, para ir aprendiendo los conceptos que manejamos en un cluster.
Pero en la realidad hay que configurar cientos de cosas más.

Hay gente que realmente sabe de instalar estas cosas de forma eficiente y mantenible... y crea plantillas PERSONALIZABLES = CHARTS de HELM


HELM Es una aplicación que nos permite hacer/gestionar despliegues de apps en un cluster de Kubernetes de forma más sencilla y eficiente, mediante la aplicación de plantillas (CHARTS)

Nuestro despliegue de WORDPRESS + MARIADB ha sido un par de ficheros que entre ambos tenían 240 lineas.
El archivo de personalización de la plantilla de MARIADB que ofrece por ejemplo la gente de BITNAMI (La más usada a nivel mundial) tiene bastantes más de 1000 lineas de código.


---

Tengo un cluster de kubernetes con 300 ns... donde tengo desplegados 250 microservicios... bbdd, caches, sistemas de mensajería...

Quiero establecer reglas de firewall para configurar las comunicaciones permitidas entre ellos.
Cuántos NP tendré que definir? CIENTOS
Eso es manejable? Mantenible?

Cada uno de esos microservicios... será en última instancia un tomcat/websphere...liberty, jboss... o similar...
De hecho es más complejo.... porque tendrán replicas!... Fácil es que acabe con 600, 700 tomcats en el cluster!
Que se van a comunicar entre si.
Como se comunican entre si? HTTP... HTTP? a secas?
HTTPS.

Qué nos da la S? de httpS? Seguridad....
En qué sentido? Qué tipos de ataque nos ayuda a frustrar la S (TLS) en HTTP?
- Man-in-the-middle (MitM) No puedo evitar este ataque... puedo frustrarlo                  ENCRIPCION
- Phishing (Suplantación de identidad). No puedo evitarlo... pero puedo frustrarlo          CERTIFICADOS
- No repudio...

Para conseguir esto, en cada servidor de aplicaciones hemos de instalar/configurar:
- Un certificado PUBLICO (mi clave publica de encriptación)
- La clave PRIVADA asociada a la clave pública
- Si los clientes también me presentan certificado, debo tener configurada/accesible el certificado publico de la CA que firma los certificados que me presentarán esos clientes... para que pueda confiar en ellos.

ServidorApp1 ----> ServidorApps2
 Presenta cert      Presenta cert.

 Y he dicho que tengo 600, 700 tomcats? a los que configurar esto? 
 Y generarles claves privadas? y certificados? Y espérate... que hay que regenerarlos cada X tiempo.


 ISTIO, a nivel de cada POD añade un contenedor más (sidecar): ENVOY (PROXY)
 De forma:

    POD1                POD2
    C1:Webserver1       C1:Webserver2
        ^v                   ^v           se hace por localhost (interna)
    C2:Envoy1  <------> C2:Envoy2
                https

---


# ServiceAccount

Es otro objeto de kubernetes.
Básicamente es como un usuario/contraseña para hacer cualquier operación contra el APISERVER.

Kubernetes no habla de usuario/contraseña. NO EXISTE ESE CONCEPTO. En Openshift SI... de hecho un Usuario de openshift es una extensión del ServiceAccount.
Con el apiserver, quien se comunica es OTRO PROGRAMA (kubectl, dashboard, oc)
Y esos programas son los que deben presentar una credencial.

A un service account, le asociamos ROLES ( hay 2 tipos en kubernetes: ClusterRole y Role).
La asociación de un ServiceAccount a un Role o ClusterRole se realiza mediante un objeto llamado RoleBinding o ClusterRoleBinding.

    Role1               RoleBinding1                  
    Role2               RoleBinding2                    ServiceAccount1

    ClusterRole1       ClusterRoleBinding1
    ClusterRole2       ClusterRoleBinding2

La definición de un Service Account es muy simple:
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: mi-service-account
  namespace: mi-namespace
```

Y la vinculación también es fácil:
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: mi-role-binding
  namespace: mi-namespace
subjects:
- kind: ServiceAccount
  name: mi-service-account
  namespace: mi-namespace
roleRef:
  kind: Role
  name: mi-role
  apiGroup: rbac.authorization.k8s.io
```

Un poco más compleja es la definición de un Role o de Un ClusterRole..
No tanto en la sintaxis... sino en las implicaciones.

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: mi-role
  namespace: mi-namespace
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list", "delete"]
```

Por ejemplo... si montásemos en el cluster un provisionador de volúmenes automático, que es un programa, que se comunicará internamente con el cluster de kubernetes... con el apiserver.

Ese programa crea los pvs... y la forma de crearlos es construir un fichero YAML y pasarlo al apiserver.
Solo que en lugar de crearlo yo humano... y pasarlo con el kubectl, ese programa crea el yaml y él lo pasa al apiserver. Y para eso necesita presentar (el programa, el provisionador) una cuenta de servicio al apiserver.

Esa cuenta por ejemplo necesita estar vinculada a un role que permita:
- create pv
- watch(monitorizar) las pvc
En kubernetes normal, no es obligatorio que los pods tengan un serviceAccount asociado, a no ser que el programa que haya dentro tenga necesidad real de comunicarse con el apiserver.

En openshift cambia la cosa. Openshift OBLIGA a que todo pod tenga un serviceAccount asociado.... aunque sea sin roles vinculados.

Openshift tiene más requisitos... y algunos muy jodidos!
El 80% de las imágenes de Docker Hub no funcionan en Openshift.
Casi todas las imagenes de docker hub utilizan (vienen creadas) con el usuario root. Y Openshift prohíbe ejecutar contenedores como root. Se puede desactivar... pero no queremos.

De hecho, redhat ofrece sus propias imagenes compatibles con openshift para la mayor parte de programas comerciales: mariadb, nginx...
Las publica en un registry QUAY.io

---

# Openshift

Un Openshift es un Kubernetes vitaminado!!! Con muchos añadidos.
En un kubernetes tenemos unos 30 objetos básicos de configuración. En Openshift empezamos con más de 300.
Me vienen de entrada muchas cosas preconfiguradas:
- IngressController
- Servidor de Métricas
- Dashboard gráfico más potente
- Gestor externo de DNS
- Provisionadores de volumenes
- Integración con Sistemas de autenticación externos: LDAP, Github
- ...

K8S - Kubernetes más estándar
K3S - Kubernetes ligero para Edge Computing
Minikube

OpenShift... realmente su nombre completo es OpenShift Container Platform (REDHAT... de pago)

Pero redhat de todos sus productos siempre tiene una versión gratuita / Opensource

            Proyecto Upstream
RHEL <----- Fedora
JBOSS <---- WildFly
OpenShift <---- OKD (Origin Community Distribution of Kubernetes that powers Red Hat OpenShift)
Ansible Tower <--- AWX

Minishift


---
                   https
        <---------------------------
         https                https
NGINX    <--- Proxy Reverso <------ Publicamente
miWeb

---

Openshift... Tanzu


Autoescalado Pods...
Pero donde está el límite? En las máquinas! (nodos)
Y si ya me he quedado sin nodos? Puedo añadir más nodos al cluster.
Pero en un cluster de kubernetes, ese trabajo ES MIO!

Eso es algo que me regalan Openshift o Tanzu.

Openshift lo puedo contratar en AWS, Azure o IBM Cloud.
Puedo configurar en Openshift un AutoEscalado de Maquinas!
Redhat ha desarrollado:
- Scripts de terraform
- Playbooks de Ansible

Y me da objetos especiales para su gestión... que defino en archivos YAML:
- Machine
- MachineSet
- MachineAutoscaler

Tanzu... hace algo parecido... os lo imagináis?
Según hace falta, crea máquinas virtuales en VMware.

De estos hay un montón: 
NUTANIX? Hyperconvergencia
Nutanix tiene su distribución de Kubernetes llamada Karbon.