# modules/firewall-rules/variables.tf

variable "project_id" {}
variable "network_name" {}

# Entrada
variable "ingress_rules" {
  description = "Lista de reglas de entrada (Ingress)"
  type = list(object({
    name          = string
    description   = optional(string)
    source_ranges = list(string) # Origen
    target_tags   = optional(list(string))
    protocol      = string
    ports         = list(string)
  }))
  default = []
}

# Salida
variable "egress_rules" {
  description = "Lista de reglas de salida (Egress)"
  type = list(object({
    name               = string
    description        = optional(string)
    destination_ranges = list(string) # Destino
    target_tags        = optional(list(string))
    protocol           = string
    ports              = list(string)
  }))
  default = []
}
