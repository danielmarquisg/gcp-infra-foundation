# Prueba de autohealing

Paramos el servicio web con `sudo systemctl stop workspace-web.service`, mediante SSH a la VM, para comprobar si el MIG lo recuperaba solo.

Para repetir la prueba, el entorno debe estar desplegado y debemos estar en la raíz del repositorio. Con una sola VM habrá un corte en la web. El entorno genera costes mientras siga desplegado; no hacer la prueba durante un `apply` o un `destroy`.

## 1. Comprobar que todo funciona

```bash
gcloud compute instance-groups managed list-instances workspace-web-mig \
  --project=gcp-infra-foundation-dm --zone=europe-west1-b \
  --format='table(instance.basename(),instanceStatus,currentAction,instanceHealth[0].detailedHealthState)'

gcloud compute backend-services get-health workspace-web-backend-service \
  --project=gcp-infra-foundation-dm --global

lab_url="http://$(terraform output -raw web_public_ip)"
curl --noproxy '*' -sS --max-time 5 \
  -o /dev/null -w 'HTTP %{http_code}\n' "$lab_url/"
```

Esperamos `RUNNING / NONE / HEALTHY` en la VM, `HEALTHY` en el backend y HTTP `200`. Antes de parar el servicio comprobamos cinco respuestas `200` seguidas. Si todavía hay errores, esperamos o revisamos el despliegue.

## 2. Abrir una segunda terminal

Aquí dejamos el estado del MIG actualizándose cada 10 segundos:

```bash
watch -n 10 "gcloud compute instance-groups managed list-instances workspace-web-mig --project=gcp-infra-foundation-dm --zone=europe-west1-b --format='table(instance.basename(),instanceStatus,currentAction,instanceHealth[0].detailedHealthState)'"
```

## 3. Parar el servicio y observar la web

En la primera terminal, sustituimos `workspace-web-XXXX` por el nombre que aparece en el listado; en nuestra prueba fue `workspace-web-xn18`.

```bash
lab_vm="workspace-web-XXXX"

gcloud compute ssh "$lab_vm" \
  --project=gcp-infra-foundation-dm --zone=europe-west1-b --tunnel-through-iap \
  --command='sudo systemctl is-active workspace-web.service'
```

Debe devolver `active`. Si no podemos conectar o el servicio ya está parado, no seguimos. Ahora lo detenemos y dejamos la respuesta HTTP actualizándose:

```bash
gcloud compute ssh "$lab_vm" \
  --project=gcp-infra-foundation-dm --zone=europe-west1-b --tunnel-through-iap \
  --command='sudo systemctl stop workspace-web.service'

watch -n 5 "curl --noproxy '*' -sS --max-time 5 -o /dev/null -w 'HTTP %{http_code}\n' '$lab_url/'"
```

Paramos la unidad systemd, no solo el contenedor: así evitamos que systemd lo reinicie por su cuenta. No arrancamos el servicio a mano; esperamos a que actúe el MIG.

Lo que esperamos ver:

- La web deja de devolver `200` y la VM deja de estar `HEALTHY`.
- El MIG empieza a repararla y aparece `RECREATING`.
- Finalmente vuelve a `RUNNING / NONE / HEALTHY` y la web devuelve `200`.

Puede tardar varios minutos y no siempre veremos todos los estados entre consultas. Si tras 10–15 minutos no vuelve, salimos de los `watch` y revisamos los errores; no es un tiempo de recuperación garantizado.

## 4. Comprobar qué ha pasado

Salimos de ambos `watch` con `Ctrl+C` y repetimos las comprobaciones del paso 1. También miramos la operación de reparación y la fecha del disco de arranque:

```bash
gcloud compute operations list \
  --project=gcp-infra-foundation-dm \
  --filter="operationType~compute.instances.repair.* AND targetLink:$lab_vm" \
  --sort-by=~insertTime --limit=5 \
  --format='yaml(operationType,status,insertTime,targetLink,error)'

lab_boot_disk="$(gcloud compute instances describe "$lab_vm" \
  --project=gcp-infra-foundation-dm --zone=europe-west1-b \
  --format='value(disks[0].source.basename())')"

gcloud compute disks describe "$lab_boot_disk" \
  --project=gcp-infra-foundation-dm --zone=europe-west1-b \
  --format='yaml(name,creationTimestamp,sourceImage)'
```

En nuestra prueba vimos HTTP `503` y `RECREATING / TIMEOUT`, y después HTTP `200` y `RUNNING / NONE / HEALTHY`. La operación `compute.instances.repair.recreateInstance` figuraba como `DONE` y el disco se había creado de nuevo durante la reparación.

La VM conservó su ID y su fecha de creación: no hace falta que cambien para confirmar el autohealing. No medimos la duración exacta del corte ni probamos todavía el autoescalado por CPU.

## Al terminar

```bash
terraform destroy
terraform state list
```

Revisamos lo que se va a borrar, incluido Artifact Registry con sus imágenes, y esperamos a que termine sin errores. El estado debe quedar vacío. Esto no elimina recursos creados fuera de Terraform ni los cargos ya generados.

Documentación de Google: [autohealing](https://docs.cloud.google.com/compute/docs/instance-groups/autohealing-instances-in-migs) y [recreación de instancias](https://docs.cloud.google.com/compute/docs/instance-groups/working-with-managed-instances#recreate_instances_in_a_mig).
