# root main.tf

# ==============================================================================
# CAPA DE INFRAESTRUCTURA 0: RED
# Revisar el plan al cambiarla: algunos atributos se actualizan y otros requieren reemplazo.
# ==============================================================================

# Compute Engine proporciona la red, las VMs, el MIG y el balanceador de este proyecto.
module "project_services" {
  source = "./modules/project-services"

  project_id = var.project_id
  services   = ["compute.googleapis.com"]
}

module "vpc" {
  source       = "./modules/vpc"
  project_id   = var.project_id
  network_name = "${var.project_id}-vpc"
  routing_mode = "REGIONAL"

  # Evita intentar crear la red mientras la API de Compute Engine sigue deshabilitada.
  depends_on = [module.project_services]
}

module "subnets" {
  source     = "./modules/subnets"
  project_id = var.project_id
  region     = var.region
  # Referenciar el output de la VPC permite a Terraform deducir la dependencia.
  network_name = module.vpc.network_name
  subnets      = var.subnets
}

# Almacén privado para las imágenes que ejecutarán las VMs reemplazables.
module "artifact_registry" {
  source = "./modules/artifact-registry"

  project_id    = var.project_id
  region        = var.region
  repository_id = "workspace-images"
}

# Las futuras VMs usarán esta identidad para descargar la imagen sin claves estáticas.
module "web_runtime_identity" {
  source = "./modules/vm-runtime-identity"

  project_id          = var.project_id
  account_id          = "workspace-web-runtime"
  repository_location = var.region
  repository_id       = module.artifact_registry.repository_id
}

# ==============================================================================
# CAPA DE INFRAESTRUCTURA 1: PERSISTENCIA (PENDIENTE)
# Espacio previsto para datos con un ciclo de vida independiente de las aplicaciones.
# ==============================================================================

# --- Ejemplo futuro: base de datos privada en Cloud SQL ---
# [TODO:] module "cloud_sql" { ... }

# ==============================================================================
# CAPA DE INFRAESTRUCTURA 2: EJECUCIÓN ESCALABLE (PENDIENTE)
# Las VMs se crearán desde una plantilla y un MIG, no como servidores individuales.
# ==============================================================================
