# Declaramos la API para que un proyecto nuevo pueda crear el repositorio sin pasos manuales.
resource "google_project_service" "artifact_registry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"

  # No desactivamos una API compartida al destruir este módulo: otros recursos podrían usarla.
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "docker" {
  project       = var.project_id
  location      = var.region
  repository_id = var.repository_id
  description   = "Imágenes Docker de Workspace Platform"
  format        = "DOCKER"

  depends_on = [google_project_service.artifact_registry]
}
