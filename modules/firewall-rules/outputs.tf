# modules/firewall-rules/outputs.tf

output "created_rules" {
  description = "Lista combinada de todas las reglas creadas (Ingress y Egress)"
  value = concat(
    [for r in google_compute_firewall.ingress_rules : r.name],
    [for r in google_compute_firewall.egress_rules : r.name]
  )
}