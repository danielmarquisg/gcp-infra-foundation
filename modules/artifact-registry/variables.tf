variable "project_id" {
  description = "ID del proyecto de GCP donde se creará el repositorio"
  type        = string
}

variable "region" {
  description = "Región donde se almacenarán las imágenes Docker"
  type        = string
}

variable "repository_id" {
  description = "Nombre del repositorio de Artifact Registry"
  type        = string
}
