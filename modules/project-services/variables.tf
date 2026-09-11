variable "project_id" {
  description = "ID del proyecto de GCP donde se habilitarán los servicios"
  type        = string
}

variable "services" {
  description = "APIs compartidas que necesita la infraestructura"
  type        = set(string)
}
