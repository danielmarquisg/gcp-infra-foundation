# root main.tf

# ==============================================================================
# CAPA DE INFRAESTRUCTURA 0: RED
# Revisar el plan al cambiarla: algunos atributos se actualizan y otros requieren reemplazo.
# ==============================================================================

module "vpc" {
  source       = "./modules/vpc"
  project_id   = var.project_id
  network_name = "${var.project_id}-vpc"
  routing_mode = "REGIONAL"
}

module "subnets" {
  source     = "./modules/subnets"
  project_id = var.project_id
  region     = var.region
  # Referenciar el output de la VPC permite a Terraform deducir la dependencia.
  network_name = module.vpc.network_name
  subnets      = var.subnets
}

module "firewall-rules" {
  source        = "./modules/firewall-rules"
  project_id    = var.project_id
  network_name  = module.vpc.network_name
  ingress_rules = var.ingress_rules_list
  egress_rules  = var.egress_rules_list
}

# ==============================================================================
# CAPA DE INFRAESTRUCTURA 1: PERSISTENCIA (PENDIENTE)
# Espacio previsto para datos con un ciclo de vida independiente de las aplicaciones.
# ==============================================================================

# --- Ejemplo futuro: base de datos privada en Cloud SQL ---
# [TODO:] module "cloud_sql" { ... }

# ==============================================================================
# CAPA DE INFRAESTRUCTURA 2: MÁQUINAS PARA LAS APLICACIONES
# Los nombres representan roles de ejemplo; este código no instala Nginx ni Flask.
# ==============================================================================

# --- Ejemplo de máquinas con IP pública ---
module "web_instances" {
  source = "./modules/instances"

  project_id = var.project_id
  zone       = var.zone

  name_prefix    = "frontend-nginx"
  instance_count = 2
  machine_type   = "e2-micro"

  # Esta clave debe existir en var.subnets; es la clave del mapa, no el nombre en GCP.
  subnet_self_link = module.subnets.subnets["frontend"].self_link
  tags             = ["frontend-web"]
  enable_public_ip = true
}

# --- Ejemplo de máquinas sin IP pública ---
module "app_instances" {
  source = "./modules/instances"

  project_id = var.project_id
  zone       = var.zone

  name_prefix    = "backend-flask"
  instance_count = 2
  machine_type   = "e2-medium"

  # Al renombrar esta clave en var.subnets, hay que actualizar también esta referencia.
  subnet_self_link = module.subnets.subnets["backend"].self_link
  tags             = ["backend-app"]
  enable_public_ip = false
}
