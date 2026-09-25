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

output "web_instance_template" {
  description = "Plantilla inmutable que utilizará el futuro Managed Instance Group"
  value = {
    name      = module.web_instance_template.name
    self_link = module.web_instance_template.self_link
  }
}

output "web_mig" {
  description = "Grupo administrado utilizado por el balanceador"
  value = {
    name                     = module.web_mig.name
    instance_group_self_link = module.web_mig.instance_group_self_link
    target_size              = module.web_mig.target_size
  }
}

output "web_lb_health_check_self_link" {
  description = "URI del health check HTTP utilizado por el balanceador"
  value       = google_compute_health_check.web_lb.self_link
}

output "web_backend_service_self_link" {
  description = "URI del servicio backend que conecta el balanceador con el MIG"
  value       = google_compute_backend_service.web.self_link
}

output "web_url_map_self_link" {
  description = "URI del mapa que dirige las peticiones al servicio backend web"
  value       = google_compute_url_map.web.self_link
}

output "web_http_proxy_self_link" {
  description = "URI del proxy HTTP que conecta el frontend con el mapa de URL"
  value       = google_compute_target_http_proxy.web.self_link
}
