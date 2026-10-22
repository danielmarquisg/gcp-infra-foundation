# Outputs de Terraform

Los outputs permiten consultar datos del despliegue sin buscarlos recurso por recurso. Esta página recoge los 16 definidos en [outputs.tf](../../outputs.tf), agrupados según su uso.

`terraform output` lee el estado guardado; no consulta el estado actual de los recursos en GCP. Ejecuta los comandos desde la raíz del repositorio y con el estado del despliegue que quieras consultar. Antes de aplicar, después de un borrado completo o tras preparar solo el registro, puede que no estén disponibles todos los outputs.

## Cómo consultarlos

```bash
terraform output
terraform output web_instance_template
terraform output -raw web_public_ip
terraform output -json web_mig
```

- Sin nombre, muestra los outputs de la raíz que estén guardados en el estado.
- Con nombre, muestra solo ese valor. Los outputs internos de los módulos no aparecen si la raíz no los expone.
- `-raw` sirve para obtener texto sin comillas ni formato adicional. También admite números y booleanos, pero no listas ni objetos.
- `-json` permite procesar listas y objetos en scripts. Con un nombre devuelve el valor; sin nombre devuelve todos los outputs con sus metadatos.

## Registro de imágenes e identidad

| Output | Qué devuelve |
| --- | --- |
| `artifact_registry_url` | Ruta base del repositorio Docker: `<region>-docker.pkg.dev/<project>/workspace-images`. |
| `web_runtime_service_account_email` | Correo de la cuenta de servicio que usan las VMs para descargar la imagen. |

Ambos son texto. La ruta del registro no incluye `https://`, el nombre de la imagen, la etiqueta ni el digest. El correo identifica la cuenta de servicio; no es una clave de acceso.

## Red

| Output | Qué devuelve |
| --- | --- |
| `vpc_name` | Nombre de la VPC. |
| `vpc_id` | Identificador de la VPC en GCP. No es el nombre corto ni debe asumirse que incluya `https://`. |
| `subnets_details` | Datos de cada subred, agrupados por su nombre en GCP. |
| `firewall_rules_created` | Lista con los nombres de las reglas de firewall creadas. |

`subnets_details` contiene, para cada subred, los campos `id`, `cidr`, `gateway` y `region`, todos de texto. Con el ejemplo del proyecto, la clave es `subnet-web`, no `web`: la primera es el nombre de GCP y la segunda es la clave de entrada en `tfvars`.

La lista del firewall reúne las reglas de entrada y después las de salida. Su posición en la lista no indica prioridad de evaluación.

## VMs, recuperación y escalado

| Output | Qué devuelve |
| --- | --- |
| `web_instance_template` | Objeto con `name` y `self_link` de la plantilla, ambos de texto. |
| `web_mig` | Objeto con `name`, `instance_group_self_link` y `target_size` del grupo. |
| `web_autoscaler_self_link` | URI del autoscaler por CPU. |
| `web_autohealing_health_check_self_link` | URI del health check utilizado por el MIG para autohealing. |

En `web_mig`, los dos primeros campos son texto y `target_size` es un número: el tamaño objetivo observado y guardado por Terraform. No es un recuento en directo de VMs encendidas o healthy.

En la configuración dejamos la entrada `target_size = null` para que mande el autoscaler. Eso no obliga al output a devolver `null`: el output lee el atributo del grupo, no esa entrada.

Para consultar las instancias actuales y su salud, usa las comprobaciones de la [guía de despliegue](../deployment.md). El autoscaler puede haber cambiado el tamaño después de que se guardara el estado.

## Balanceador

| Output | Qué devuelve |
| --- | --- |
| `web_public_ip` | IPv4 pública del balanceador, sin protocolo ni puerto. |
| `web_lb_health_check_self_link` | URI del health check que decide qué VMs reciben tráfico. |
| `web_backend_service_self_link` | URI del backend service conectado al grupo de instancias. |
| `web_url_map_self_link` | URI del mapa que dirige las peticiones al backend. |
| `web_http_proxy_self_link` | URI del proxy HTTP que utiliza el mapa de URL. |
| `web_forwarding_rule_self_link` | URI de la regla que recibe las conexiones HTTP públicas. |

Todos son texto. Los `self_link` identifican recursos de la API de Google Cloud; no son direcciones para abrir la aplicación. Para visitar la web usamos la IP del balanceador con `http://`.

## Usarlos en Bash

```bash
lab_registry="$(terraform output -raw artifact_registry_url)"
lab_url="http://$(terraform output -raw web_public_ip)"
printf '%s\n' "$lab_registry" "$lab_url"
```

`-raw` no añade un salto de línea; `printf` permite mostrar los valores sin que queden pegados al prompt.

Revisa la salida antes de compartirla. Las opciones `-raw` y `-json` pueden mostrar en claro valores marcados como sensibles.

Referencia de HashiCorp: [comando terraform output](https://developer.hashicorp.com/terraform/cli/commands/output).
