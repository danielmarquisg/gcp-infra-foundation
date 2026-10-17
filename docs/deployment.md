# Desplegar y borrar el entorno

Recorrido actual: construir la web desde este repositorio, probarla, publicar la imagen y desplegar la infraestructura. No hace falta tener guardada la imagen `workspace-web:0.2`: construiremos otra, con su propio digest.

Ejecuta los comandos desde la raíz del repositorio, en Bash. Necesitas Terraform 1.3 o superior, Google Cloud CLI, Docker con Buildx y un proyecto existente con facturación activa. Tu cuenta debe poder crear los recursos de Terraform y publicar imágenes en Artifact Registry.

El estado es local porque el backend GCS está comentado. Conserva el estado hasta terminar el borrado; clonar el repositorio en otro equipo no recupera un despliegue existente. No gestionar el mismo entorno desde estados independientes.

## 1. Preparar la configuración

Si todavía no tienes `terraform.tfvars`, copia [el ejemplo](../terraform.tfvars.example). No sobrescribas tu configuración si ya existe:

```bash
test -f terraform.tfvars || cp terraform.tfvars.example terraform.tfvars
```

Edita el proyecto, la región y la zona. Conserva la clave `web` en las subredes. El digest de ceros del ejemplo sirve para preparar el registro, pero hay que sustituirlo antes de desplegar las VMs.

En esta terminal, pon el mismo proyecto y zona que en `terraform.tfvars`:

```bash
lab_project="your-gcp-project-id"
lab_zone="europe-west1-b"

gcloud auth login
gcloud config set project "$lab_project"
gcloud auth application-default login
```

El primer login es para la CLI; el de Application Default Credentials es el que utiliza Terraform. [Google explica esta autenticación local aquí](https://docs.cloud.google.com/docs/terraform/authentication).

## 2. Construir y probar la imagen localmente

```bash
docker buildx build --platform linux/amd64 --load -t workspace-web:demo ./web
docker run --rm --name workspace-web-preview --platform linux/amd64 \
  -p 127.0.0.1:8080:80 workspace-web:demo
```

Fijamos [la plataforma](https://docs.docker.com/reference/cli/docker/buildx/build/) a `linux/amd64` para las VMs actuales. ARM no soportado sin emulación.

Deja el contenedor funcionando y abre `http://127.0.0.1:8080/`. Revisar la aplicación web. Desde otra terminal puedes comprobar:

```bash
curl --noproxy '*' -sS --max-time 10 \
  -o /dev/null -w 'HTTP %{http_code}\n' http://127.0.0.1:8080/
```

Esperamos HTTP `200` y que las páginas se vean bien. Si falla, no publiques la imagen. Al terminar, vuelve a la primera terminal y pulsa `Ctrl+C`; `--rm` elimina ese contenedor de prueba.

## 3. Crear el registro y publicar

A partir de aquí se crean recursos en GCP. El almacenamiento de imágenes puede generar costes.

```bash
./scripts/bootstrap.sh
```

Revisa el plan antes de responder `y`. Enter o `n` cancela. El script inicializa Terraform y prepara solo Artifact Registry; todavía no crea VMs ni balanceador. El aviso de `-target` corresponde a esa preparación inicial, no al despliegue completo.

Cuando termine correctamente, en la terminal:

```bash
lab_registry="$(terraform output -raw artifact_registry_url)"
gcloud auth configure-docker "${lab_registry%%/*}"

docker tag workspace-web:demo "$lab_registry/workspace-web:demo"
docker push "$lab_registry/workspace-web:demo"

gcloud artifacts docker images list "$lab_registry/workspace-web" \
  --project="$lab_project" --include-tags
```

Copia a `workspace_web_image_digest`, en `terraform.tfvars`, el digest `sha256:...` de la versión etiquetada como `demo`. Es el digest publicado en el registro, no el ID local de `docker image inspect`.

La etiqueta ayuda a localizar la imagen; las VMs usarán el digest. Reconstruir desde el código no garantiza obtener el mismo digest de una compilación anterior. Todavía no tenemos publicación automática ni una copia de la imagen fuera de este registro. [Referencia de Google para publicar imágenes](https://docs.cloud.google.com/artifact-registry/docs/docker/pushing-and-pulling).

## 4. Desplegar la infraestructura

```bash
terraform plan -out=deployment.tfplan
```

Revisa el proyecto, la imagen y todos los recursos propuestos. Este plan es completo, sin `-target`.

El siguiente comando crea VMs, discos y el balanceador: generan costes mientras existan, aunque no visites la web. Aplicar un plan guardado no vuelve a pedir confirmación. Si todo es correcto, aplica el archivo revisado:

```bash
terraform apply deployment.tfplan
```

Si cambias la configuración, genera y revisa otro plan antes de aplicar.

## 5. Comprobar que funciona

```bash
gcloud compute instance-groups managed list-instances workspace-web-mig \
  --project="$lab_project" --zone="$lab_zone" \
  --format='table(instance.basename(),instanceStatus,currentAction,instanceHealth[0].detailedHealthState)'

gcloud compute backend-services get-health workspace-web-backend-service \
  --project="$lab_project" --global

lab_url="http://$(terraform output -raw web_public_ip)"
printf '%s\n' "$lab_url"
curl --noproxy '*' -sS --max-time 10 \
  -o /dev/null -w 'HTTP %{http_code}\n' "$lab_url/"
```

Esperamos `RUNNING / NONE / HEALTHY` en la VM, `HEALTHY` en el backend y HTTP `200`. El primer arranque puede tardar varios minutos; repite las comprobaciones y confirma varias respuestas `200` seguidas antes de probar fallos o carga. También puedes abrir la URL en el navegador.

Las pruebas de [autohealing](tests/autohealing.md) y [autoescalado](tests/autoscaling.md) van aparte: no hacen falta para comprobar un despliegue normal.

## 6. Borrar al terminar

Desde la misma configuración y estado:

```bash
terraform plan -destroy -out=destroy.tfplan
```

Revisa el borrado: también se eliminará Artifact Registry con todas sus imágenes. Si eso es lo que quieres, aplica el plan; no habrá otra confirmación:

```bash
terraform apply destroy.tfplan
terraform state list
```

Espera a que termine sin errores. El estado debe quedar vacío. Si se interrumpe o falla, conserva el estado, revisa lo pendiente y genera otro plan de destrucción; no reutilices el anterior.

Comprueba también en GCP que no queden las VMs, discos, balanceador, IP reservada ni el repositorio de este despliegue. Un estado vacío no demuestra que no haya recursos creados fuera de Terraform. El borrado no anula los cargos ya generados.

Los planes y el estado no se suben a Git: pueden contener información sensible. Si necesitas repetir el entorno, vuelve a publicar la imagen antes de arrancar las VMs. [Referencia de HashiCorp sobre planes guardados y de destrucción](https://developer.hashicorp.com/terraform/cli/commands/plan).
