# root main.tf

# ==============================================================================
# INFRA LAYER 0: NETWORK FOUNDATION
# (Base inmutable: VPC, Subnets, Firewall. Si esto cambia, se destruye todo)
# ==============================================================================

module "vpc" {
  source       = "./modules/vpc"
  project_id   = var.project_id
  region       = var.region
  network_name = "${var.project_id}-vpc"
  routing_mode = "REGIONAL"
}

module "subnets" {
  source       = "./modules/subnets"
  project_id   = var.project_id
  region       = var.region
  network_name = module.vpc.network_name
  subnets      = var.subnets

  # DEPENDENCIA EXPLÍCITA
  # Aunque Terraform ya lo sabe por "network_name" (implícita), esto fuerza
  # a que el módulo VPC termine todas sus operaciones antes de empezar aquí.
  depends_on = [module.vpc]
}

module "firewall-rules" {
  source        = "./modules/firewall-rules"
  project_id    = var.project_id
  network_name  = module.vpc.network_name
  ingress_rules = var.ingress_rules_list
  egress_rules  = var.egress_rules_list

  depends_on = [module.subnets]
}

# ==============================================================================
# INFRA LAYER 1: DATA PERSISTENCE (Stateful)
# (Datos: Bases de datos, Discos, Storage. Tardan en crearse)
# ==============================================================================

# --- Software Tier 3: Database (Private / Cloud SQL) ---
# [TODO:] module "cloud_sql" { ... }

# ==============================================================================
# INFRA LAYER 2: COMPUTE & APPLICATIONS (Stateless)
# (Efímero: Arquitectura de Software de 3 Capas)
# ==============================================================================

# --- Software Tier 1: Frontend (Public / Nginx) ---
module "web_instances" {
  source = "./modules/instances"

  project_id = var.project_id
  region     = var.region
  zone       = var.zone

  name_prefix    = "frontend-nginx"
  instance_count = 2
  machine_type   = "e2-micro"

  subnet_name      = var.subnets["frontend"].name
  tags             = ["frontend-web"]
  enable_public_ip = true

  depends_on = [module.subnets]
}

# --- Software Tier 2: Backend (Private / Flask) ---
module "app_instances" {
  source = "./modules/instances"

  project_id = var.project_id
  region     = var.region
  zone       = var.zone

  name_prefix    = "backend-flask"
  instance_count = 2
  machine_type   = "e2-medium"

  subnet_name      = var.subnets["backend"].name
  tags             = ["backend-app"]
  enable_public_ip = false

  depends_on = [module.subnets]
}
