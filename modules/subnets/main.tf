# modules/subnets/main.tf

resource "google_compute_subnetwork" "subnetwork" {
  # Las claves del mapa identifican los recursos; renombrarlas cambia su dirección en el estado.
  for_each = var.subnets

  name          = each.value.name
  ip_cidr_range = each.value.cidr
  region        = var.region
  project       = var.project_id
  network       = var.network_name
  # Permite acceso a APIs de Google desde VMs sin IP pública, con rutas y firewall adecuados.
  # No proporciona salida general a Internet; para eso las VMs privadas necesitan, por ejemplo, Cloud NAT.
  private_ip_google_access = true
}
