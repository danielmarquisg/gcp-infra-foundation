# GCP Infra Foundation

Infraestructura como código con Terraform para ejecutar una carga web contenerizada en Google Cloud.

El diseño utiliza máquinas virtuales privadas y reemplazables dentro de un Managed Instance Group (MIG), detrás de un balanceador de carga externo y con capacidad de autoescalado.

## Arquitectura

```mermaid
flowchart LR
    Internet --> LB[External Application Load Balancer]
    LB --> MIG[Managed Instance Group]
    AR[Artifact Registry] --> Template[Instance Template]
    Template --> MIG
    Autoscaler --> MIG
    MIG --> VMs[VM privadas con workspace-web]
```

El balanceador será el único punto de entrada público. Las VM compartirán una plantilla y podrán reemplazarse automáticamente: se administran como ganado, no como mascotas.

## Estado del proyecto

Los checks representan funcionalidades implementadas en el repositorio, no necesariamente servicios en ejecución. En GCP ya están aplicados la red, el firewall, Artifact Registry, la identidad de las VM, la Instance Template y el MIG, configurado con cero instancias. La imagen `workspace-web:0.2` está publicada en Artifact Registry.

- [x] Foundation modular con VPC, subredes y firewall.
- [x] Primera implementación con VM individuales, públicas y privadas.
- [x] Retirada del modelo de VM individuales para adoptar infraestructura inmutable.
- [x] Repositorio privado de imágenes en Artifact Registry.
- [x] Identidad dedicada con permisos mínimos de lectura.
- [x] Política de firewall versionada para IAP y el balanceador.
- [x] Instance Template basada en la imagen publicada.
- [x] Managed Instance Group configurado para crear VM privadas y reemplazables.
- [x] Health check HTTP definido para la web.
- [ ] External Application Load Balancer.
- [ ] Política de autoescalado.
- [ ] Despliegue y prueba del recorrido completo.

## Componentes

| Componente | Responsabilidad |
| --- | --- |
| `modules/project-services` | Habilita las APIs necesarias. |
| `modules/vpc` | Crea la red VPC custom. |
| `modules/subnets` | Gestiona las subredes. |
| `modules/firewall-rules` | Crea reglas de firewall reutilizables. |
| `firewall.tf` | Define la política de acceso del proyecto. |
| `modules/artifact-registry` | Gestiona el repositorio de imágenes Docker. |
| `modules/vm-runtime-identity` | Crea la identidad utilizada por las VM. |

## Seguridad

- Las VM no tendrán IP pública.
- SSH estará limitado a Google IAP.
- El puerto `80` solo aceptará tráfico del balanceador y sus health checks.
- La identidad de las VM solo puede leer imágenes de `workspace-images`.
- La política de firewall está versionada en `firewall.tf`.
