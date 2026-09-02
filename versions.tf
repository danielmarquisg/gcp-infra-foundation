# root versions.tf

terraform {
  required_version = ">= 1.3"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" # "~>" permite 5.1, 5.2, etc., pero NO 6.0
    }
  }
}
