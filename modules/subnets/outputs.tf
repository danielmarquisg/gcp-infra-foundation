# modules/subnets/outputs.tf

output "subnets" {
  description = "Nombre de la Subnet creada"
  value       = google_compute_subnetwork.subnetwork
}
