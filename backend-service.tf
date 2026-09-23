# root backend-service.tf

resource "google_compute_backend_service" "web" {
  project               = var.project_id
  name                  = "workspace-web-backend-service"
  description           = "Distribuye tráfico HTTP entre las VMs web disponibles"
  protocol              = "HTTP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  timeout_sec           = 30

  # Coincide con el puerto http:80 declarado por el MIG.
  port_name     = "http"
  health_checks = [google_compute_health_check.web_lb.self_link]

  backend {
    group           = module.web_mig.instance_group_self_link
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}
