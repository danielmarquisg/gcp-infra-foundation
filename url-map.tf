# root url-map.tf

resource "google_compute_url_map" "web" {
  project     = var.project_id
  name        = "workspace-web-url-map"
  description = "Dirige las peticiones del balanceador al servicio backend web"

  # Sin un mapeo específico, todo el tráfico se envía al backend service web.
  default_service = google_compute_backend_service.web.self_link
}

