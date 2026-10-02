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
  description = "Tamaño fijo del grupo; null permite que lo gestione un autoscaler"
  type        = number
  default     = 0

  validation {
    condition = var.target_size == null ? true : (
      var.target_size >= 0 && floor(var.target_size) == var.target_size
    )
    error_message = "target_size debe ser null o un número entero no negativo."
  }
}

variable "autohealing" {
  description = "Health check y margen de arranque para recrear VMs unhealthy; null desactiva la política"
  type = object({
    health_check_self_link = string
    initial_delay_sec      = optional(number, 300)
  })
  default = null

  validation {
    condition = var.autohealing == null ? true : (
      var.autohealing.initial_delay_sec >= 0 &&
      var.autohealing.initial_delay_sec <= 3600 &&
      floor(var.autohealing.initial_delay_sec) == var.autohealing.initial_delay_sec
    )
    error_message = "initial_delay_sec debe ser un número entero entre 0 y 3600 segundos."
  }
}
