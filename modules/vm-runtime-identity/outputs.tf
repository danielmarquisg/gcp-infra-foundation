output "service_account_email" {
  description = "Correo de la cuenta de servicio que se asociará a las VMs"
  value       = google_service_account.runtime.email
}

output "service_account_id" {
  description = "ID completo de la cuenta de servicio"
  value       = google_service_account.runtime.id
}
