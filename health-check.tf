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

  # En un proyecto nuevo, espera a que Compute Engine esté disponible.
  depends_on = [module.project_services]
}

resource "google_compute_health_check" "web_autohealing" {
  project     = var.project_id
  name        = "workspace-web-autohealing-health-check"
  description = "Comprueba el servicio HTTP para recrear VMs web que dejan de responder"

  # Exigimos varios fallos consecutivos para no recrear la VM por un fallo puntual.
  check_interval_sec  = 30
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    # Comprobamos la portada para verificar que Nginx sirve el contenido de la aplicación.
    port         = 80
    request_path = "/"
  }

  depends_on = [module.project_services]
}
