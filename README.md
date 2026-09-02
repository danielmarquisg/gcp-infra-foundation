# GCP Infra Foundation

Este repositorio es un proyecto de **Infrastructure as Code con Terraform sobre Google Cloud**.

El objetivo principal no es desplegar todavía una aplicación completa, sino construir una **base de infraestructura modular y reutilizable** sobre la que poder seguir creciendo.

En este punto del proyecto me he centrado sobre todo en aprender y demostrar cómo organizar Terraform separando responsabilidades en módulos: red, subredes, reglas de firewall e instancias de Compute Engine.

La infraestructura deja preparada la base para una futura arquitectura con frontend y backend separados, pero **todavía no hay una aplicación desplegada**.

Actualmente este repositorio **no incluye**:

* Load Balancer.
* Contenedores.
* Docker.
* Kubernetes.
* Una aplicación frontend.
* Una API Flask desplegada.
* Base de datos.
* Cloud SQL.

Los nombres `frontend-nginx` y `backend-flask` representan el papel que tendrán esas máquinas más adelante, pero por ahora el repositorio se centra únicamente en la **infraestructura**.

La siguiente evolución del proyecto será desplegar una aplicación real sobre esta base y añadir un **Load Balancer**, manteniendo la misma idea de infraestructura modular.

## Qué despliega

La infraestructura actual crea:

* Una **VPC custom** sin subredes automáticas.
* Dos subredes:

  * `subnet-frontend` → `10.10.10.0/24`
  * `subnet-backend` → `10.10.20.0/24`
* Reglas de firewall separadas para tráfico de entrada y salida.
* Dos máquinas virtuales para la futura capa frontend.
* Dos máquinas virtuales para la futura capa backend.
* Acceso SSH mediante **Google IAP**.
* **OS Login** habilitado en las instancias.

La arquitectura actual queda, de forma simplificada, así:

```text
Internet
   |
   | HTTP / HTTPS permitido por firewall
   v
+--------------------------+
| Frontend subnet          |
| 10.10.10.0/24            |
|                          |
| frontend-nginx-01        |
| frontend-nginx-02        |
| Public IP: sí            |
+------------+-------------+
             |
             | TCP 5000 permitido
             v
+--------------------------+
| Backend subnet           |
| 10.10.20.0/24            |
|                          |
| backend-flask-01         |
| backend-flask-02         |
| Public IP: no            |
+--------------------------+
```

No existe todavía un Load Balancer delante de las máquinas frontend ni una aplicación escuchando en estos puertos. Las reglas y la separación de red dejan preparada la infraestructura para esa siguiente fase.

## Por qué está organizado en módulos

Una de las partes principales de este proyecto era evitar escribir todos los recursos directamente en un único `main.tf`.

He separado los distintos componentes de infraestructura en módulos independientes:

```text
.
├── backend.tf
├── main.tf
├── outputs.tf
├── providers.tf
├── terraform.tfvars
├── variables.tf
├── versions.tf
└── modules
    ├── firewall-rules
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── variables.tf
    │   └── versions.tf
    ├── instances
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── variables.tf
    │   └── versions.tf
    ├── subnets
    │   ├── main.tf
    │   ├── outputs.tf
    │   ├── variables.tf
    │   └── versions.tf
    └── vpc
        ├── main.tf
        ├── outputs.tf
        ├── variables.tf
        └── versions.tf
```

De esta forma, el `main.tf` raíz se encarga principalmente de conectar los módulos y pasarles la configuración necesaria.

La idea es que los módulos no estén ligados únicamente a los valores actuales del proyecto. Siempre que ha sido posible, los datos que pueden cambiar se reciben mediante variables.

Esto permite reutilizar la misma lógica para crear nuevos recursos sin duplicar bloques completos de Terraform.

## `modules/vpc`

Este módulo crea la VPC principal del proyecto.

He desactivado `auto_create_subnetworks` para utilizar una red custom y controlar yo mismo qué subredes existen y qué rangos IP utilizan.

El modo de routing también se recibe mediante una variable y actualmente utilizo `REGIONAL`.

## `modules/subnets`

Este módulo crea las subredes a partir de un mapa recibido como variable.

Por ejemplo:

```hcl
subnets = {
  "frontend" = {
    name = "subnet-frontend"
    cidr = "10.10.10.0/24"
  }

  "backend" = {
    name = "subnet-backend"
    cidr = "10.10.20.0/24"
  }
}
```

Gracias a esto puedo añadir otra subnet a la infraestructura modificando la configuración sin tener que crear manualmente otro bloque `google_compute_subnetwork`.

Las subredes también tienen habilitado `private_ip_google_access`.

## `modules/firewall-rules`

Este módulo gestiona las reglas de firewall.

En lugar de crear cada regla de forma independiente dentro del módulo, las reglas de entrada y salida se pasan como colecciones de objetos.

Después utilizo `for_each` para crear los recursos.

Esto hace que pueda modificar las reglas desde la configuración del entorno sin tener que cambiar la lógica interna del módulo.

Actualmente tengo reglas para:

* SSH mediante el rango oficial de **Google IAP**.
* ICMP entre las redes internas.
* HTTP y HTTPS hacia las máquinas frontend.
* TCP `5000` desde la subnet frontend hacia las máquinas backend.
* Salida TCP por `80` y `443`.

Las reglas reflejan cómo quiero que se comunique la futura aplicación, aunque esa aplicación todavía no forma parte de este repositorio.

## `modules/instances`

Este módulo crea instancias de Compute Engine.

Lo he hecho reutilizable para poder utilizar el mismo módulo tanto para frontend como para backend cambiando únicamente sus variables.

Entre otras cosas puedo configurar:

* Número de instancias.
* Prefijo del nombre.
* Tipo de máquina.
* Imagen del sistema operativo.
* Zona.
* Subred.
* Network tags.
* Si las máquinas deben tener IP pública.

Por ejemplo, desde el mismo módulo puedo crear:

```text
frontend-nginx-01
frontend-nginx-02
```

y:

```text
backend-flask-01
backend-flask-02
```

con configuraciones diferentes.

## Frontend

La futura capa frontend está formada por **2 instancias `e2-micro`** dentro de `subnet-frontend`.

Actualmente tienen IP pública.

```text
Tags: frontend-web
Puertos permitidos: 80 y 443
SSH: Google IAP
```

El nombre de las instancias indica que la idea es utilizar **Nginx** en la siguiente fase del proyecto, pero Nginx todavía no se instala ni configura desde este repositorio.

## Backend

La futura capa backend está formada por **2 instancias `e2-medium`** dentro de `subnet-backend`.

Estas máquinas no tienen IP pública.

```text
Tags: backend-app
Puerto permitido: 5000
Origen permitido: 10.10.10.0/24
SSH: Google IAP
```

La idea es que más adelante estas máquinas ejecuten la API de la aplicación y que el acceso al puerto de la aplicación venga únicamente desde la red frontend.

Actualmente no hay ninguna API Flask desplegada.

## Variables

La configuración principal del entorno está centralizada en `terraform.tfvars`.

Por ejemplo:

```hcl
project_id = "gcp-infra-foundation-dm"
region     = "europe-west1"
zone       = "europe-west1-b"
```

Además de los valores básicos del proyecto, utilizo variables para definir elementos como:

* Subredes.
* Reglas de firewall.
* Configuración de las instancias.
* Número de máquinas.
* Tipos de máquina.
* Network tags.
* Direccionamiento.

Mi intención es mantener la lógica dentro de los módulos y dejar fuera de ellos los valores que pueden cambiar dependiendo del entorno.

## Outputs

Después del despliegue Terraform devuelve información útil de los recursos creados:

* Nombre de la VPC.
* ID de la VPC.
* Información de las subredes.
* Reglas de firewall creadas.
* IPs internas y públicas de las máquinas frontend.
* IPs internas de las máquinas backend.

```bash
terraform output
```

## Requisitos

Para desplegar el proyecto necesito:

* Terraform `>= 1.3`
* Provider de Google `~> 5.0`
* Un proyecto de Google Cloud.
* Autenticación configurada contra GCP.
* Permisos para crear recursos de red y Compute Engine.

Para autenticación local:

```bash
gcloud auth application-default login
```

## Despliegue

Inicializar Terraform:

```bash
terraform init
```

Comprobar los cambios:

```bash
terraform plan
```

Crear la infraestructura:

```bash
terraform apply
```

Eliminarla:

```bash
terraform destroy
```

## Estado de Terraform

La configuración del backend remoto en **Google Cloud Storage** está preparada y ya la he probado.

Para un proyecto en el que trabajasen varias personas, mantendría el `terraform.tfstate` en remoto para que todo el equipo trabajase sobre el mismo estado y no dependiese de archivos locales de cada desarrollador.

En este repositorio lo he dejado en local de forma intencionada porque actualmente trabajo yo solo y lo utilizo principalmente para mis propias pruebas y para seguir iterando sobre la infraestructura.

Si el proyecto pasara a un entorno colaborativo, volvería a utilizar el backend remoto en GCS.


## Referencias

Para plantear la estructura de los módulos me he guiado principalmente por estos dos proyectos de `terraform-google-modules`:

* [Terraform Google Network](https://github.com/terraform-google-modules/terraform-google-network/tree/main)
* [Terraform Google VM](https://github.com/terraform-google-modules/terraform-google-vm)

No utilizo estos módulos directamente en el proyecto. Los he usado como referencia para entender cómo estructurar módulos reutilizables, separar variables y outputs y dividir los distintos componentes de infraestructura.

## Estado actual

La primera fase del proyecto está centrada en construir la foundation de infraestructura:

* [x] VPC custom.
* [x] Subnets frontend y backend.
* [x] Reglas de firewall modularizadas.
* [x] Acceso SSH mediante IAP.
* [x] OS Login.
* [x] Instancias frontend.
* [x] Instancias backend privadas.
* [x] Módulo reutilizable para Compute Engine.
* [x] Variables y outputs separados.
* [ ] Backend remoto de Terraform en GCS.
* [ ] Cloud NAT para las máquinas privadas.
* [ ] Aplicación frontend.
* [ ] API backend.
* [ ] Load Balancer.
* [ ] Persistencia / base de datos.
* [ ] Containerización de frontend y backend.
* [ ] Creación de imágenes de la aplicación.
* [ ] Despliegue en Kubernetes.

## Siguiente fase

El siguiente paso será utilizar esta infraestructura como base para desplegar una aplicación real.

La idea es añadir progresivamente:

```text
Internet
   |
   v
Load Balancer
   |
   v
Frontend
   |
   v
Backend
   |
   v
Database
```

En esta fase ya entrarían la aplicación, el balanceo de carga y la capa de persistencia, manteniendo la infraestructura definida con Terraform y reutilizando los módulos creados en este repositorio.

Este primer repositorio se queda **intencionadamente** antes de ese punto porque su objetivo principal es trabajar la **foundation de GCP y la modularización de Terraform**: crear componentes pequeños, reutilizables y configurables que después pueda seguir utilizando a medida que la arquitectura crezca.

A partir de ahí, el proyecto seguirá evolucionando hacia una arquitectura más cercana a un entorno real de producción.

La fase final será migrar las cargas de trabajo a **Kubernetes**, containerizando primero la aplicación y generando las imágenes necesarias para poder desplegarla dentro de pods.

Entre otras cosas, quiero trabajar:

* Containerización del frontend y backend.
* Creación y versionado de las imágenes de la aplicación.
* Despliegue de esas imágenes en Kubernetes mediante pods.
* Gestión de configuración y secretos con **Google Secret Manager**.
* Control de acceso y permisos siguiendo el principio de mínimo privilegio.
* Seguridad de red y comunicación entre servicios.
* Protección de credenciales y datos sensibles.
* Revisión de las imágenes y configuración de los contenedores.
* Exposición segura de los servicios.
* Análisis de las distintas superficies de ataque de la arquitectura.
* Aplicación progresiva de medidas de hardening sobre la infraestructura, los contenedores y los workloads.

La idea final no es únicamente conseguir que la aplicación funcione dentro de Kubernetes, sino entender también **cómo empaquetarla correctamente, cómo desplegarla, qué componentes quedan expuestos, cómo puede ser atacada y qué controles puedo aplicar para reducir esos riesgos**.
