# modules/firewall-rules/main.tf

# Reglas de entrada
resource "google_compute_firewall" "ingress_rules" {
  for_each = { for r in var.ingress_rules : r.name => r }

  name          = each.value.name
  description   = lookup(each.value, "description", null)
  network       = var.network_name
  project       = var.project_id
  direction     = "INGRESS"
  source_ranges = each.value.source_ranges
  target_tags   = each.value.target_tags

  allow {
    protocol = each.value.protocol
    ports    = each.value.ports
  }
}

# Reglas de salida
resource "google_compute_firewall" "egress_rules" {
  for_each = { for r in var.egress_rules : r.name => r }

  name               = each.value.name
  description        = lookup(each.value, "description", null)
  network            = var.network_name
  project            = var.project_id
  direction          = "EGRESS"
  destination_ranges = each.value.destination_ranges
  target_tags        = each.value.target_tags

  allow {
    protocol = each.value.protocol
    ports    = each.value.ports
  }
}
