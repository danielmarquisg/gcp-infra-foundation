# modules/instance-template/variables.tf

variable "project_id" {
  description = "ID del proyecto de GCP donde se creará la plantilla"
  type        = string
}

variable "name_prefix" {
  description = "Prefijo utilizado para versionar las plantillas de instancia"
  type        = string
}

variable "machine_type" {
  description = "Tipo de máquina que utilizarán las instancias del MIG"
  type        = string
  default     = "e2-micro"
}

variable "source_image" {
  description = "Imagen concreta de Container-Optimized OS utilizada por la plantilla"
  type        = string

  validation {
    condition     = can(regex("^projects/cos-cloud/global/images/cos-[a-z0-9-]+$", var.source_image))
    error_message = "source_image debe identificar una imagen concreta del proyecto cos-cloud."
  }
}

variable "subnetwork_self_link" {
  description = "Self link de la subred privada asociada a las instancias"
  type        = string
}

variable "service_account_email" {
  description = "Correo de la identidad que utilizarán las instancias"
  type        = string
}

variable "container_image" {
  description = "URI completa de la imagen Docker fijada mediante digest SHA-256"
  type        = string

  validation {
    condition     = can(regex("@sha256:[0-9a-f]{64}$", var.container_image))
    error_message = "container_image debe terminar en @sha256 seguido de un digest hexadecimal de 64 caracteres."
  }
}

variable "network_tags" {
  description = "Etiquetas de red utilizadas para seleccionar las reglas de firewall"
  type        = set(string)
  default     = []
}

variable "boot_disk_size_gb" {
  description = "Tamaño en GiB del disco de arranque de cada instancia"
  type        = number
  default     = 10

  validation {
    condition     = var.boot_disk_size_gb >= 10 && floor(var.boot_disk_size_gb) == var.boot_disk_size_gb
    error_message = "boot_disk_size_gb debe ser un número entero igual o superior a 10."
  }
}
