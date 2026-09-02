# modules/subnets/outputs.tf

output "subnets" {
  description = "Mapa con los datos necesarios de las subredes creadas"
  value = {
    for key, subnet in google_compute_subnetwork.subnetwork : key => {
      name            = subnet.name
      id              = subnet.id
      self_link       = subnet.self_link # Identificador completo; crea la dependencia implícita.
      cidr            = subnet.ip_cidr_range
      gateway_address = subnet.gateway_address
      region          = subnet.region
    }
  }
}
