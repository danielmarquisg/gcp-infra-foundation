# modules/instance-template/outputs.tf

output "name" {
  description = "Nombre generado para la versión actual de la plantilla"
  value       = google_compute_instance_template.web.name
}

output "self_link" {
  description = "URI de la plantilla que utilizará el Managed Instance Group"
  value       = google_compute_instance_template.web.self_link
}
