# modules/subnets/variables.tf

variable "project_id" {
  description = "ID del proyecto de GCP donde se crearán las subredes"
  type        = string
}

variable "region" {
  description = "Región de GCP donde se crearán las subredes"
  type        = string
}

variable "network_name" {
  description = "Nombre de la VPC a la que pertenecerán las subredes"
  type        = string
}

variable "subnets" {
  description = "Mapa de subnets"
  type = map(object({
    name = string
    cidr = string
  }))
}
