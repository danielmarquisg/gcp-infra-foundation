# Cómo funciona la infraestructura

La web se ejecuta en contenedores Docker dentro de VMs privadas. Un Managed Instance Group (MIG) crea esas VMs desde una plantilla y un balanceador HTTP recibe las peticiones de los usuarios.

## Por qué usamos VMs reemplazables

Si una VM falla, el MIG puede recrearla desde la misma plantilla, sin preparar otra VM manualmente.

Por eso los cambios de la web van en una imagen Docker, no entrando por SSH a editar archivos. Un cambio manual se perdería al reemplazar la VM y dejaría al grupo con versiones distintas.

[main.tf](../main.tf) conecta los módulos. Los archivos `.tf` de la raíz forman una sola configuración; no son scripts que se ejecuten uno detrás de otro.

## De la imagen a una VM funcionando

Usamos dos imágenes distintas:

- **COS:** es el sistema operativo con el que arranca la VM.
- **La imagen Docker:** contiene Nginx y los archivos de la web, preparados con [web/Dockerfile](../web/Dockerfile).

La imagen Docker se publica en Artifact Registry antes de arrancar las VMs. Terraform no la construye ni la sube. Usamos `workspace_web_image_digest` para descargar una versión exacta, aunque alguien cambie después una etiqueta como `0.2`.

La [Instance Template](../modules/instance-template/main.tf) reúne la configuración de la VM y del arranque del contenedor. No es una VM: el [MIG](../modules/managed-instance-group/main.tf) la utiliza para crear las instancias.

Al arrancar, [cloud-init](../modules/instance-template/cloud-init.yaml.tftpl) configura un servicio de systemd que descarga la imagen y ejecuta el contenedor. Así cada VM puede levantar la web sin que entremos a instalar Nginx.

La VM usa su [Service Account](../modules/vm-runtime-identity/main.tf), con permiso de lectura solo sobre el repositorio de imágenes. Puede descargar, pero no publicar otra versión. Así no necesita nuestras credenciales personales ni una clave JSON.

## Cómo llega una petición a la web

El recorrido es `navegador → balanceador HTTP → VM privada → Nginx`.

El usuario conecta con la [IP pública del balanceador](../frontend.tf), en el puerto `80`. El [proxy HTTP](../http-proxy.tf) utiliza el [mapa de URL](../url-map.tf) para dirigir la petición al backend service. Todos los dominios y rutas van al mismo backend.

El [backend service](../backend-service.tf) conecta con las VMs del MIG que están healthy, donde Nginx sirve los archivos. El MIG administra las VMs; no es otra máquina por la que pase la petición.

Las VMs no tienen IP pública para no exponer cada máquina a Internet. El [firewall](../firewall.tf) limita HTTP a los rangos de Google del balanceador y los health checks, y SSH a IAP. El servicio usa HTTP, sin HTTPS.

## Quién recupera el servicio y quién añade VMs

- **systemd** puede volver a arrancar el contenedor si el proceso termina. Sigue siendo la misma VM.
- **El health check del balanceador** comprueba si la web responde y permite apartar del tráfico una VM que falla. No crea otra VM.
- **El health check de autohealing** permite al MIG detectar un fallo del servicio y recrear la VM.
- **El autoscaler** ajusta el número de VMs según el uso medio de CPU. No mide directamente cuántas visitas recibe la web.

Los health checks están en [health-check.tf](../health-check.tf) y la política de CPU en [autoscaler.tf](../autoscaler.tf).

Con una sola VM puede haber un corte mientras se recupera el servicio. El grupo está en una sola zona: tampoco cubrimos la caída de toda esa zona.

Lo que comprobamos está recogido en las pruebas de [autohealing](tests/autohealing.md) y [autoescalado](tests/autoscaling.md).

## Qué ocurre al borrar el entorno

Un `terraform destroy` completo elimina las VMs, el balanceador y también Artifact Registry con sus imágenes. El entorno se pueda borrar entero.

Para reconstruirlo, primero hay que crear el registro y volver a publicar la imagen. El código en Git no se borra, pero tampoco conserva por sí solo la imagen Docker. El borrado no elimina recursos ajenos a este estado ni los cargos ya generados.

## Para ampliar

- [Cómo organiza Terraform los archivos y módulos](https://developer.hashicorp.com/terraform/language/files).
- [Grupos de instancias de Google Cloud](https://docs.cloud.google.com/compute/docs/instance-groups).
- [Application Load Balancer externo](https://docs.cloud.google.com/load-balancing/docs/https).
