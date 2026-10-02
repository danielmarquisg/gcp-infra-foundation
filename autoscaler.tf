# root autoscaler.tf

resource "google_compute_autoscaler" "web" {
  project     = var.project_id
  zone        = var.zone
  name        = "workspace-web-autoscaler"
  description = "Ajusta el número de VMs web según el uso medio de CPU del grupo"

  # El autoscaler controla el administrador del MIG, no el grupo utilizado por el balanceador.
  target = module.web_mig.instance_group_manager_self_link

  autoscaling_policy {
    mode = "ON"

    # Fija una VM como capacidad mínima para atender peticiones.
    min_replicas = 1
    # Limita el tamaño del autoscaler; una actualización puede crear una VM adicional temporal.
    max_replicas = 3

    # Excluye la CPU de las VMs que arrancan al calcular aumentos de capacidad.
    cooldown_period = 300

    cpu_utilization {
      # El objetivo es un 60 % de CPU media del grupo, no un número de peticiones.
      target = 0.6
    }
  }
}
