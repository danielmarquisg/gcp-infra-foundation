# root frontend.tf

resource "google_compute_global_address" "web" {
  project      = var.project_id
  name         = "workspace-web-ip"
  description  = "Dirección IPv4 pública y estable del balanceador web"
  address_type = "EXTERNAL"
  ip_version   = "IPV4"

  # Evita reservar la dirección mientras Compute Engine sigue habilitándose.
  depends_on = [module.project_services]
}

resource "google_compute_global_forwarding_rule" "web_http" {
  project               = var.project_id
  name                  = "workspace-web-http-forwarding-rule"
  description           = "Recibe tráfico HTTP público y lo envía al proxy web"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  network_tier          = "PREMIUM"

  # El frontend escucha en la IP estable y entrega las conexiones HTTP al proxy.
  ip_address  = google_compute_global_address.web.address
  ip_protocol = "TCP"
  port_range  = "80"
  target      = google_compute_target_http_proxy.web.self_link
}
