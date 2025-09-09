
# Operador

Son programas que nos permiten automatizar trabajos / operaciones dentro del cluster. Es como un "Operador humano" convertido en programa. Suelen venir con CRDs (Custom Resource Definitions) que nos permiten "darle a este programa órdenes" (Lenguaje imperativo)... Lo que realmente nos permiten esos CRDs es explicarle a esos programas las tareas que quiero que realicen (LENGUAJE DECLARATIVO).

Ese operador puede instalarse con:
- Archivos de manifiesto
- Helm Chart

> Ejemplo: Mariadb-operator

1. Instalar Operador Mariadb en vuestro propio namespace
2. Crear una instancia de BBDD (MariaDB)
3. Configurar que se haga un backup semanal


> Ejemplo: NFS Subdir External Provisioner

$ helm install nfs-subdir-external-provisioner 
               nfs-subdir-external-provisioner/
               nfs-subdir-external-provisioner
                --set nfs.server=x.x.x.x 
                --set nfs.path=/exported/path

Además de server y path, necesitamos personalizar?
- namespace

Cuando se pida un volumen (pvc), que hace en kubernetes que éste provisionador y no otro entre en acción para despachar el volumen (pv)? El storageClassName

Cuando creemos el provisionador, le vamos a dar un StorageClassName

En todo cluster, hay un storageClass por defecto. Si no le decimos nada a un PVC, se va a usar el storageClass por defecto. Debemos decirle a nuestro provisioner si es el que es el storageClass por defecto o no. -> NO

Cómo se llamarán los directorios que se vayan creando?
${namespace}/${pvcName}

ivan/mariadb