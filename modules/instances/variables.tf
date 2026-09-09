# modules/instances/variables.tf

variable "project_id" {
  description = "ID del proyecto de GCP donde se crearán las máquinas"
  type        = string
}

variable "zone" {
  description = "Zona de GCP donde se crearán las máquinas"
  type        = string
}

variable "name_prefix" {
  description = "Prefijo para el nombre de las maquinas (ej: web-server)"
  type        = string
}

variable "instance_count" {
  description = "Cantidad de réplicas a crear; 0 permite no crear ninguna"
  type        = number
  default     = 1

  validation {
    # El tipo number también acepta decimales; floor comprueba que no haya parte fraccionaria.
    condition     = var.instance_count >= 0 && floor(var.instance_count) == var.instance_count
    error_message = "La cantidad de instancias debe ser un número entero mayor o igual que 0."
  }
}

variable "machine_type" {
  description = "Tipo de maquina (ej: e2-micro)"
  type        = string
  default     = "e2-micro"
}

variable "subnet_self_link" {
  description = "Self link de la subred donde se conectarán las máquinas"
  type        = string
}

variable "tags" {
  description = "Etiquetas de firewall para todas las replicas"
  type        = list(string)
  default     = []
}

variable "image" {
  # La familia debian-12 selecciona una imagen vigente; no fija una versión exacta del disco.
  description = "Imagen del SO"
  type        = string
  default     = "debian-cloud/debian-12"
}

variable "enable_public_ip" {
  description = "Define si las maquinas tendran IP publica efimera"
  type        = bool
  default     = false
}
