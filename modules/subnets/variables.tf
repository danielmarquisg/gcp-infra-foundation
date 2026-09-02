# modules/subnets/variables.tf

variable "project_id" {}
variable "region" {}
variable "network_name" {}

variable "subnets" {
  description = "Mapa de subnets"
  type = map(object({
    name = string
    cidr = string
  }))
}
