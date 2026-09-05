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
  description = "Mapa de subredes con su nombre y rango IPv4 en formato CIDR"
  type = map(object({
    name = string
    cidr = string
  }))

  validation {
    condition = alltrue([
      for subnet in values(var.subnets) : can(cidrnetmask(subnet.cidr))
    ])
    error_message = "Cada subred debe tener un rango IPv4 válido en formato CIDR, por ejemplo 10.10.10.0/24."
  }
}
