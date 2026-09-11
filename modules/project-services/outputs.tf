output "enabled_services" {
  description = "APIs gestionadas por este módulo"
  value       = sort(keys(google_project_service.enabled))
}
