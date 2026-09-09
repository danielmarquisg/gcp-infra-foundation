# root versions.tf

terraform {
  # optional(...) en los objetos de variables requiere Terraform 1.3 o superior.
  required_version = ">= 1.3"
  # El rango permite actualizar; .terraform.lock.hcl conserva la versión exacta seleccionada.
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0" # Permite versiones 7.x, pero no 8.0
    }
  }
}
