# modules/instances/main.tf

variable "project_id" {}
variable "region" {}
variable "zone" {}

variable "name_prefix" {
  description = "Prefijo para el nombre de las maquinas (ej: web-server)"
  type        = string
}

variable "instance_count" {
  description = "Cantidad de replicas a crear"
  type        = number
  default     = 1

}

variable "machine_type" {
  description = "Tipo de maquina (ej: e2-micro)"
  type        = string
  default     = "e2-micro"
}

variable "subnet_name" {
  description = "Nombre de la subred donde se conectaran"
  type        = string
}

variable "tags" {
  description = "Etiquetas de firewall para todas las replicas"
  type        = list(string)
  default     = []
}

variable "image" {
  description = "Imagen del SO"
  default     = "debian-cloud/debian-12"
}

variable "enable_public_ip" {
  description = "Define si las maquinas tendran IP publica efimera"
  type        = bool
  default     = false
}
