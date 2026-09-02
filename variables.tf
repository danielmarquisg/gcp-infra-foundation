# root variables.tf

variable "project_id" {
  description = "ID del proyecto de GCP (gcp-infra-foundation-dm)"
  type        = string
}

variable "region" {
  description = "Región por defecto para los recursos"
  type        = string
  default     = "europe-west1" # europe-southwest1 (Madrid)
}

variable "zone" {
  description = "Zona por defecto para las instancias"
  type        = string
  default     = "europe-west1-b" # europe-southwest1-a 
}

variable "subnets" {
  description = "Mapa de subnets"
  type = map(object({
    name = string
    cidr = string
  }))

}

variable "ingress_rules_list" {
  description = "Lista de reglas de firewall de entrada"
  type = list(object({
    name          = string
    description   = optional(string)
    source_ranges = list(string)
    target_tags   = optional(list(string))
    protocol      = string
    ports         = list(string)
  }))
}

variable "egress_rules_list" {
  description = "Lista de reglas de firewall de salida"
  type = list(object({
    name               = string
    description        = optional(string)
    destination_ranges = list(string)
    target_tags        = optional(list(string))
    protocol           = string
    ports              = list(string)
  }))
  default = []
}
