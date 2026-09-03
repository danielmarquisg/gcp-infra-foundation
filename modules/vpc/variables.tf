# modules/vpc/variables.tf

variable "project_id" {
  description = "ID del proyecto de GCP donde se creará la VPC"
  type        = string
}

variable "network_name" {
  description = "Nombre de la VPC"
  type        = string
  default     = "default-vpc"
}

variable "routing_mode" {
  description = "Modo de enrutamiento de la VPC (GLOBAL o REGIONAL)"
  type        = string
  default     = "GLOBAL"

  validation {
    condition     = contains(["GLOBAL", "REGIONAL"], var.routing_mode)
    error_message = "El modo de enrutamiento debe ser GLOBAL o REGIONAL."
  }
}
