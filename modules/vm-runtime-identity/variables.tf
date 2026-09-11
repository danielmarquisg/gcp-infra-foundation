variable "project_id" {
  description = "ID del proyecto de GCP donde se creará la cuenta de servicio"
  type        = string
}

variable "account_id" {
  description = "Identificador de la cuenta de servicio"
  type        = string
}

variable "repository_location" {
  description = "Región del repositorio que contiene la imagen Docker"
  type        = string
}

variable "repository_id" {
  description = "ID del repositorio que las VMs podrán leer"
  type        = string
}
