# modules/vpc/outputs.tf

output "network_name" {
  description = "Nombre de la VPC creada"
  value       = google_compute_network.network.name
}
output "network_id" {
  description = "ID global (URI) de la VPC"
  value       = google_compute_network.network.id
}
