# modules/vpc/main.tf

resource "google_compute_network" "network" {
  name    = var.network_name
  project = var.project_id
  # Controlamos los rangos IP creando nuestras propias subredes en el módulo subnets.
  auto_create_subnetworks = false
  routing_mode            = var.routing_mode
}
