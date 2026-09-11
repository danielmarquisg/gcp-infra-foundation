resource "google_project_service" "enabled" {
  for_each = var.services

  project = var.project_id
  service = each.value

  # Una API es compartida por varios recursos y no debe apagarse al retirar este módulo.
  disable_on_destroy = false
}
