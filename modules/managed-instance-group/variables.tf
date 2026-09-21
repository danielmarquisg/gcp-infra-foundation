# modules/managed-instance-group/variables.tf

variable "project_id" {
  description = "ID del proyecto donde se crea el grupo administrado"
  type        = string
}

variable "zone" {
  description = "Zona donde el grupo crea sus instancias"
  type        = string
}

variable "name" {
  description = "Nombre del grupo administrado"
  type        = string
}

variable "base_instance_name" {
  description = "Prefijo de las VMs reemplazables que crea el grupo"
  type        = string
}

variable "instance_template_self_link" {
  description = "URI de la plantilla que define cada VM del grupo"
  type        = string
}

variable "target_size" {
  description = "Número de VMs que el grupo debe mantener"
  type        = number
  default     = 0

  validation {
    condition     = var.target_size >= 0 && floor(var.target_size) == var.target_size
    error_message = "target_size debe ser un número entero no negativo."
  }
}
