# root outputs.tf

output "vpc_name" {
  description = "Nombre de la VPC creada"
  value       = module.vpc.network_name
}

output "vpc_id" {
  description = "ID global (URI) de la VPC"
  value       = module.vpc.network_id
}

output "subnets_details" {
  description = "Mapa consolidado con toda la información de las subredes"
  value = {
    # Para la consulta final usamos el nombre de GCP como clave, no la clave de var.subnets.
    for subnet in module.subnets.subnets : subnet.name => {
      id      = subnet.id
      cidr    = subnet.cidr
      gateway = subnet.gateway_address
      region  = subnet.region
    }
  }
}

output "firewall_rules_created" {
  description = "Lista de reglas de firewall desplegadas"
  value       = module.firewall-rules.created_rules
}

output "artifact_registry_url" {
  description = "Ruta base del repositorio Docker de Artifact Registry"
  value       = module.artifact_registry.repository_url
}

output "web_runtime_service_account_email" {
  description = "Correo de la identidad utilizada por las VMs de la aplicación web"
  value       = module.web_runtime_identity.service_account_email
}
