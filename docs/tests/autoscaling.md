# Prueba de autoescalado por CPU

Generamos carga de CPU con dos bucles dentro de una VM para comprobar si el autoscaler añadía instancias y volvía a dejar una al parar la carga.

Para repetir la prueba, el entorno debe estar desplegado y debemos estar en la raíz del repositorio. Genera costes mientras siga desplegado, incluidas las VMs adicionales. No hacer la prueba durante un `apply` o un `destroy`.

La política permite entre una y tres VMs, con un objetivo de CPU media del 60 %. Los comandos usan el proyecto de esta prueba; si usamos otro, cambiamos `--project`.

## 1. Comprobar que todo funciona

```bash
gcloud compute instance-groups managed list-instances workspace-web-mig \
  --project=gcp-infra-foundation-dm --zone=europe-west1-b \
  --format='table(instance.basename(),instanceStatus,currentAction,instanceHealth[0].detailedHealthState)'

lab_url="http://$(terraform output -raw web_public_ip)"
curl --noproxy '*' -sS --max-time 10 \
  -o /dev/null -w 'HTTP %{http_code}\n' "$lab_url/"
```

Esperamos una VM en `RUNNING / NONE / HEALTHY` y HTTP `200`. Si todavía hay errores, revisamos el despliegue antes de generar carga.

## 2. Abrir una segunda terminal

Aquí dejamos el estado del MIG actualizándose cada 10 segundos:

```bash
watch -n 10 "gcloud compute instance-groups managed list-instances workspace-web-mig --project=gcp-infra-foundation-dm --zone=europe-west1-b --format='table(instance.basename(),instanceStatus,currentAction,instanceHealth[0].detailedHealthState)'"
```

## 3. Generar carga en la primera terminal

Sustituimos `workspace-web-XXXX` por la VM del listado; en nuestra prueba fue `workspace-web-cq0t`.

```bash
lab_vm="workspace-web-XXXX"

gcloud compute ssh "$lab_vm" \
  --project=gcp-infra-foundation-dm --zone=europe-west1-b --tunnel-through-iap \
  --command='systemctl is-active workspace-web.service && command -v systemd-run && uptime'
```

Debe mostrar `active` y la ruta de `systemd-run`. La VM debe llevar al menos cinco minutos encendida: el autoscaler ignora su CPU durante los primeros 300 segundos al decidir si añade instancias.

Lanzamos la carga una sola vez:

```bash
gcloud compute ssh "$lab_vm" \
  --project=gcp-infra-foundation-dm --zone=europe-west1-b --tunnel-through-iap \
  --command="sudo systemd-run \
    --unit=workspace-web-cpu-test \
    --service-type=exec \
    --property=RuntimeMaxSec=600s \
    --property=KillMode=control-group \
    --property=TimeoutStopSec=5s \
    --property=Nice=10 \
    /bin/sh -c 'while :; do :; done & while :; do :; done & wait'"
```

Los dos bucles consumen CPU sin modificar la aplicación. Systemd los ejecuta en una unidad temporal, con menor prioridad, y empieza a detenerlos al llegar a los diez minutos. Cerrar SSH o el `watch` no detiene la carga.

En la segunda terminal esperamos ver nuevas VMs pasando por `CREATING` y `VERIFYING`, hasta llegar a `RUNNING / NONE / HEALTHY`. El grupo puede aumentar a dos o tres VMs; no tiene que hacerlo de una en una.

## 4. Parar la carga y esperar la reducción

En la primera terminal detenemos la unidad de prueba, no el servicio web:

```bash
gcloud compute ssh "$lab_vm" \
  --project=gcp-infra-foundation-dm --zone=europe-west1-b --tunnel-through-iap \
  --command='sudo systemctl stop workspace-web-cpu-test.service'
```

Si la carga ya terminó automáticamente, la unidad puede no aparecer. Mantenemos el `watch` sin borrar VMs ni cambiar Terraform: esperamos que el autoscaler vuelva a dejar una sola VM.

La reducción tarda varios minutos por la estabilización del autoscaler y el cierre de conexiones del balanceador. Si tras unos 20 minutos sin carga queda más de una VM, revisamos el autoscaler; no es un plazo garantizado.

Cuando quede una VM en `RUNNING / NONE / HEALTHY`, salimos del `watch` con `Ctrl+C` y comprobamos la web:

```bash
curl --noproxy '*' -sS --max-time 10 \
  -o /dev/null -w 'HTTP %{http_code}\n' "$lab_url/"
```

## Lo que vimos

El grupo pasó de una a tres VMs y las tres llegaron a `HEALTHY`. Al parar la carga, dos pasaron a `DELETING` y quedó `workspace-web-gt2w` en `RUNNING / NONE / HEALTHY`. Comprobamos la web con el navegador y con `curl` al terminar, y funcionaba correctamente.

Probamos el aumento y la reducción por CPU (`1 → 3 → 1`), no el rendimiento de la web bajo tráfico HTTP. Los bucles solo se ejecutaban en la VM inicial; no se repartían entre las nuevas instancias.

## Al terminar

```bash
terraform destroy
terraform state list
```

Revisamos las eliminaciones, incluido Artifact Registry con sus imágenes, y esperamos a que termine sin errores. En nuestra prueba se destruyeron los 20 recursos y el estado quedó vacío. Esto no elimina recursos creados fuera de Terraform ni los cargos ya generados.

Documentación de Google: [autoescalado por CPU](https://docs.cloud.google.com/compute/docs/autoscaler/scaling-cpu) y [decisiones del autoscaler](https://docs.cloud.google.com/compute/docs/autoscaler/understanding-autoscaler-decisions).
