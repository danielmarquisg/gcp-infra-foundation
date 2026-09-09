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

output "frontend_web_info" {
  description = "IPs Públicas e Internas de los servidores Web"
  value       = module.web_instances.instances_info
}

output "backend_internal_info" {
  # Conserva el mismo esquema de salida que las VMs públicas, con public_ip = null.
  description = "Solo IPs Internas de los servidores de Backend"
  value       = module.app_instances.instances_info
}
