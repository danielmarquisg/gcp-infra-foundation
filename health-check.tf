# root health-check.tf

resource "google_compute_health_check" "web_lb" {
  project             = var.project_id
  name                = "workspace-web-lb-health-check"
  description         = "Comprueba la respuesta HTTP de las VMs web para el balanceador"
  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    # La demo estática no tiene /health; la portada devuelve 200 cuando Nginx responde.
    port         = 80
    request_path = "/"
  }
}
