# modules/firewall-rules/variables.tf

variable "project_id" {
  description = "ID del proyecto de GCP donde se crearán las reglas de firewall"
  type        = string
}

variable "network_name" {
  description = "Nombre de la VPC donde se aplicarán las reglas de firewall"
  type        = string
}

# Entrada
# Si se omite target_tags, la regla se aplica a todas las VMs de la VPC.
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
# destination_ranges limita destinos; target_tags selecciona las VMs desde las que sale el tráfico.
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
