# Declaramos la API para que la identidad pueda crearse también en proyectos nuevos.
resource "google_project_service" "iam" {
  project = var.project_id
  service = "iam.googleapis.com"

  # No desactivamos una API compartida al destruir este módulo.
  disable_on_destroy = false
}

# La VM usa una identidad propia en lugar de credenciales personales o claves estáticas.
resource "google_service_account" "runtime" {
  project      = var.project_id
  account_id   = var.account_id
  display_name = "Workspace web runtime"
  description  = "Identidad de las VMs que ejecutan la aplicación web"

  depends_on = [google_project_service.iam]
}

# Limitamos la lectura a este repositorio para aplicar el principio de mínimo privilegio.
resource "google_artifact_registry_repository_iam_member" "image_reader" {
  project    = var.project_id
  location   = var.repository_location
  repository = var.repository_id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.runtime.email}"
}
