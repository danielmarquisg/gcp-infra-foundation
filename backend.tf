# backend.tf

# Al estar comentado el backend GCS, Terraform guarda el estado localmente.
# Activarlo requiere un bucket existente y una migración del estado; no basta con descomentarlo.

# terraform {
#   backend "gcs" {
#     bucket  = "bucket de gcp"
#     prefix  = "terraform/state"
#   }
# }
