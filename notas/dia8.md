
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