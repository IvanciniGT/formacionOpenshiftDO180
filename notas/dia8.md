
- Instalar un nfs server (cada cliente de estos que usamos para conectar al cluster)
  - /data/nfs
- Instalar un provisionador que ofrece kubernetes (sigs): nfs-subdir-external-provisioner.
  
  A ese provisionador le configuramos: El servidor y carpeta NFS
  También le configuramos:
  - El storageClass al que va a asociado: `volumen-tipo-ivan`
  - La nomenclatura que ibamos a usar para los nombres de las subcarpetas.
     namespace/pvcName 

  Este provisionador lo que hace es cuando se solicita una pvc nueva, asociado al StorageClass que registra el provisionador, crea un subdirectorio dentro del path que le hemos indicado en el servidor nfs. 

- A partir de este momento, cualquier PVC que hagamos con ese StorageClass (y accessModes compatibles) es gestionado por el provisionador.


---

Al crear una pvc y tener un provisionador, el provisionador crea el volumen real en el backend de turno (en nuestro caso en el nfs server), crea un pv y lo asocia a la pvc.

Si por algún motivo borramos la pvc, el pv queda en estado released o incluso se borra. Con el volumen real, pasa lo mismo, dependiendo de la configuración del provisionador, el volumen puede mantenerse o incluso también eliminarse. Si se borra, perdemos los datos. Pero incluso si no se borra, los datos están en un sitio, al que kubernetes a priori no va a acceder a de nuevo.

PVC (Mariadb) -> Provisionador PV: mariadb1029487167189237684 -> /data/nfs/ivan/mariadb1029487167189237684
                                                                 Cabina fibra: LUN 1029487167189237684

Borro la PVC -> PV queda en released o borrado -> /data/nfs/ivan/mariadb1029487167189237684 queda o se borra (jodido o no... quizás quiero que se borre).

Si pasa lo anterior... al crear una PVC nueva, va a apuntar a un nuevo volumen... no al antiguo... Y si necesito recuperar los datos, lo tendré que hacer a mano!

Y digo que esto puede pasar.. y pasa a la mínima.
En muchos casos, no soy yo quien crea la pvc, la crea por ejemplo HELM. Y como se me ocurra hacer un uninstall helm me borra la pvc. A veces, no me queda otra que hacer un uninstall helm y volver a instalarlo, ya que cambio cosas que no se permiten modificar en caliente... y es necesario hacer un borrado de un recurso.



----


Kubernetes SOLO entiende de sus objetos. POD, SECRET...
        ^                            ^            ^
      KUBECTL                     OPERADOR       CRDs
        ^                           v   ^         ^
      fichero                     - Monitoriza   Humano
     manifiesto                     CRDs
      ^     ^                     - Genera Objetos 
   humano  HELM                     nuevos de Kubernetes 
           ^  ^                     (es como si escribiera archivos de manifiesto)
       CHART  values
               ^
              HUMANO

---

1. Ampliar el cluster √
2. Instalar Ingress Controller (NGINX) √ 
3. ElasticSearch (Operador)        
---> Empezáis vosotros... 10-15 minutos:
     1 nodo de elasticsearch (solo 1)
     Nada más
     Almacenamiento efímero.

    OPERADOR: elastic cloud operator for kubernetes

---

# Ingress

  - Regla de configuración para un proxy reverso

# Ingress Controller

  - UN proxy reverso del que puedo tener varias réplicas (IDENTICAS - HA+Escalabilidad)
  - Programa que :
      - Monitoriza los recursos Ingress que se crean en el cluster
      - Configura el proxy reverso de turno con su sintaxis propia en base a las reglas que se definen en los recursos Ingress

## Me puede interesar tener más de un ingress Controller instalado en el cluster?

- En proxy reverso tendrá por delante un SERVICE (tipo LoadBalancer)... eso implica que habrá una IP en la red de FUERA DEL CLUSTER Que balanceará petición entre los nodos del cluster.

Y qué pasa si tengo mis nodos conectados a varias redes!
- Red pública (accesible por los usuarios)
- Red privada (accesible solo por servidores que están dentro de la empresa y quieren acceder a servicios que están dentro del cluster)
- Red privada de gestión (accesible solo por administradores de sistemas)
- Red privada donde hay otras BBDD, servicios que necesitan los programas de mi cluster.





                                            Nombres que se asocian 
                                            a un IngressController
INGRESS                                     | INGRESS CLASSES |   INGRESS CONTROLLER
--------------------------------------------+-----------------+---------------------------
- Configuración básica PROXY REVERSO        | nginx-ivan --------> nginx-ingress-controller-ivan
   host + path -> servicio:puerto           |                 |          proxy reverso: nginx (1 réplica o 14)
- Certificados si quiero https              |                 |             su configuración: nginx.conf (cada una con el 
                                            |                 |                                      fichero de configuración... el mismo todas)
- Configuración avanzada del proxy reverso  |                 |          programa que MONITORIZA las reglas Ingress que se crean
   - Redirecciones especiales               |                 |                 y si esa regla tiene el mismo IngressClass que éste,
   - Tamaño del cuerpo máximo               |                 |                 toma los datos que vienen dentro del ingress
   - Timeouts                               |                 |                 y los añade al fichero de configuración del proxy reverso
   - Configuración de cabeceras             |                 |                    ---> nginx.conf
- IngressClass (nginx-ivan)                 | nginx-menchu --------> envoy-ingress-controller-menchu

---

Este parámetro es requerido por ES... a nivel del kernel de Linux.
Si esto no arranca.
vm.max_map_count=262144 

Puedo entrar en los nodos (si los tengo identificados) donde se vaya a desplegar el ES y meter eso... como root.
Pero aún así, es pan para hoy y hambra pa' mañana..
El día de mañana, que aumente el cluster...y le meta otras 25 máquinas... Me voy a acordar de actualizar este parámetro en todas las nuevas máquinas que meta en el cluster? BUFFF ! Lo dejaré por ahí apuntado... a ver si el próximo administrador que venga (que yo ya estaré en otra empresa que me paguen más €€€€) se acuerda de actualizarlo.

Lo que me podría interesar es que esto se haga en automático!... en todas las máquinas del cluster.
Cómo podría yo hacer que un programa se ejecute en TODAS las máquinas del cluster? Un DAEMONSET.
Lo que hace un daemonset es abrir un pod en cada nodo del cluster (o en los nodos que yo le diga... por etiquetas).

Pero ese pod, lo que ejecuta en última instancia es un CONTENEDOR.
Dentro de ese contenedor es donde querría yo ejecutar el sysctl -w vm.max_map_count=262144 para que haga el cambio...
1º Ese comando acaba? o se queda ahí corriendo como demonio?
   Al acabar.. no me vale esta solución... Podemos trampearla:
   - Lo puedo ejecutar como un initContainer (el comando)
   - Y creo un contenedor que haga un sleep infinity...

Pero... la cosa es peor... Puedo ejecutar ese comando desde un contenedor? A priori no.
A no ser que tenga un contenedor privilegado (privileged: true), que permita hacer cambios en el kernel.