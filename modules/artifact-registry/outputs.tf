output "repository_id" {
  description = "ID del repositorio de Artifact Registry"
  value       = google_artifact_registry_repository.docker.repository_id
}

output "repository_url" {
  # Esta es la ruta base; el nombre y la versión de la imagen se añadirán al publicar.
  description = "Ruta base para etiquetar y publicar imágenes Docker"
  value       = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.docker.repository_id}"
}
