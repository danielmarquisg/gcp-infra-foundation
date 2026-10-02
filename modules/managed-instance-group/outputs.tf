# modules/managed-instance-group/outputs.tf

output "name" {
  description = "Nombre del Managed Instance Group"
  value       = google_compute_instance_group_manager.web.name
}

output "instance_group_self_link" {
  description = "URI del grupo de instancias que utilizará el balanceador"
  value       = google_compute_instance_group_manager.web.instance_group
}

output "instance_group_manager_self_link" {
  description = "URI del administrador del MIG utilizado por el autoscaler"
  value       = google_compute_instance_group_manager.web.self_link
}

output "target_size" {
  description = "Tamaño objetivo observado del grupo"
  value       = google_compute_instance_group_manager.web.target_size
}
