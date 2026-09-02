# modules/subnets/main.tf

resource "google_compute_subnetwork" "subnetwork" {
  for_each = var.subnets

  name                     = each.value.name
  ip_cidr_range            = each.value.cidr
  region                   = var.region
  project                  = var.project_id
  network                  = var.network_name
  private_ip_google_access = true # Permite a las VMs privadas llegar a las APIs de Google
}
