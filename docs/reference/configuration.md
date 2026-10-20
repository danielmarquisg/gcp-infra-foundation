# Entradas de Terraform

Estas son las cinco entradas de la configuración raíz. En el uso local las asignamos en `terraform.tfvars`, que no se sube a Git. El archivo [terraform.tfvars.example](../../terraform.tfvars.example) sirve como punto de partida.

Las definiciones están en [variables.tf](../../variables.tf). Esta página recoge sus tipos y restricciones; los pasos para preparar y desplegar el entorno están en la [guía de despliegue](../deployment.md).

## Resumen

| Variable | Tipo | Obligatoria | Valor predeterminado |
| --- | --- | --- | --- |
| `project_id` | `string` | Sí | Sin valor predeterminado |
| `region` | `string` | No | `"europe-west1"` |
| `zone` | `string` | No | `"europe-west1-b"` |
| `workspace_web_image_digest` | `string` | Sí | Sin valor predeterminado |
| `subnets` | `map(object({ name = string, cidr = string }))` | Sí | Sin valor predeterminado |

Obligatoria significa que debes aportar un valor: el código no define uno por defecto. Los valores del archivo de ejemplo no son valores predeterminados de Terraform.

## Proyecto y ubicación

- `project_id`: ID del proyecto existente donde se crean los recursos. El destino de Terraform lo determina esta variable, no el proyecto seleccionado en la CLI de `gcloud`.
- `region`: región de las subredes y de Artifact Registry. Todas las subredes del mapa usan esta región; no convierte el balanceador global en uno regional.
- `zone`: zona del MIG y del autoscaler. Debe pertenecer a la región de la subred que utilizan las VMs.

No hay validaciones propias para estas tres entradas. La configuración no comprueba que el proyecto exista ni que la zona pertenezca a la región; GCP también exige ubicaciones compatibles, facturación y permisos adecuados.

## Imagen de la aplicación

`workspace_web_image_digest` recibe únicamente el digest publicado, con este formato:

```text
sha256:<64 caracteres hexadecimales en minúsculas>
```

No recibe una etiqueta como `0.2` ni la URL completa de la imagen. [main.tf](../../main.tf) lo combina con el repositorio `workspace-images` y la imagen `workspace-web`.

La validación exige el prefijo `sha256:` seguido de 64 caracteres de `0` a `9` o de `a` a `f`. Comprueba el formato, no que la imagen exista en Artifact Registry. Terraform tampoco la construye ni la publica.

El digest de ceros del ejemplo es solo un marcador: pasa esa comprobación de formato, pero no identifica una imagen disponible. Hay que sustituirlo por el digest real antes de desplegar las VMs.

## Subredes

`subnets` es un mapa. Cada entrada tiene dos campos obligatorios de tipo `string`:

- `name`: nombre de la subred en GCP.
- `cidr`: rango IPv4 en formato CIDR.

Por ejemplo:

```hcl
subnets = {
  web = {
    name = "subnet-web"
    cidr = "10.10.10.0/24"
  }
}
```

`web` es la clave de Terraform; `subnet-web` es el nombre visible en GCP. No tienen que coincidir. La clave `web` es obligatoria porque la plantilla selecciona esa subred desde `main.tf`.

Se pueden añadir otras entradas al mapa: crean subredes, pero no despliegan aplicaciones en ellas. Las claves identifican recursos mediante `for_each`; renombrarlas puede provocar su reemplazo.

Hay dos comprobaciones en el código:

- La raíz exige que exista la clave `web`.
- El [módulo de subredes](../../modules/subnets/variables.tf) comprueba que todos los rangos tengan formato CIDR IPv4 válido.

No se comprueban los solapamientos entre rangos ni los nombres de GCP mediante estas validaciones.

## Qué no se configura en tfvars

El tipo de VM y la versión de COS están definidos en [main.tf](../../main.tf); la política de acceso, en [firewall.tf](../../firewall.tf); y el autoescalado, en [autoscaler.tf](../../autoscaler.tf). No son entradas de la configuración raíz.

Las variables de los módulos se conectan en sus bloques `module`. Añadir esos nombres a `terraform.tfvars` no los conecta con el módulo.

Cambiar un valor puede modificar o reemplazar recursos existentes. Revisa el plan antes de aplicar; no es solo un cambio de configuración local.

Referencia de HashiCorp: [variables de entrada](https://developer.hashicorp.com/terraform/language/values/variables) y [tipos de datos](https://developer.hashicorp.com/terraform/language/expressions/type-constraints).
