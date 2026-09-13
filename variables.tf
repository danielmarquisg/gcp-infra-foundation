# root variables.tf

variable "project_id" {
  description = "ID del proyecto de GCP (gcp-infra-foundation-dm)"
  type        = string
}

variable "region" {
  description = "Región por defecto para los recursos"
  type        = string
  default     = "europe-west1" # europe-southwest1 (Madrid)
}

variable "zone" {
  # Debe pertenecer a la región de la subred que utilizarán las VMs.
  description = "Zona por defecto para las instancias"
  type        = string
  default     = "europe-west1-b" # europe-southwest1-a 
}

variable "workspace_web_image_digest" {
  description = "Digest SHA-256 de la imagen inmutable que ejecutarán las VMs web"
  type        = string

  validation {
    condition     = can(regex("^sha256:[0-9a-f]{64}$", var.workspace_web_image_digest))
    error_message = "workspace_web_image_digest debe tener el formato sha256 seguido de 64 caracteres hexadecimales."
  }
}

variable "subnets" {
  # La clave identifica la subred en Terraform; name define su nombre en GCP.
  description = "Mapa de subnets"
  type = map(object({
    name = string
    cidr = string
  }))

}
