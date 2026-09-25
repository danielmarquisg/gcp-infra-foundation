# root http-proxy.tf

resource "google_compute_target_http_proxy" "web" {
  project     = var.project_id
  name        = "workspace-web-http-proxy"
  description = "Conecta el frontend HTTP del balanceador con el mapa de URL"

  # El proxy delega en el mapa de URL la selección del servicio backend.
  url_map = google_compute_url_map.web.self_link
}
