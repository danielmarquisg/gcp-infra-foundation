# root providers.tf

# Centralizamos el proveedor para que los módulos hijos hereden esta configuración.
# En local usamos Application Default Credentials (gcloud auth application-default login).
provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}
