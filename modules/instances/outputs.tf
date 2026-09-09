# modules/instances/outputs.tf

output "instances_info" {
  description = "Lista de nombres e IPs de las maquinas creadas"
  value = [
    for vm in google_compute_instance.vm : {
      name        = vm.name
      internal_ip = vm.network_interface[0].network_ip
      # nat_ip contiene la IPv4 pública de la interfaz, no la de un servicio Cloud NAT.
      # Comprobamos si existe access_config antes de acceder a [0], para evitar Invalid index.
      # null expresa ausencia de IP pública sin mezclar direcciones con mensajes de texto.
      public_ip = length(vm.network_interface[0].access_config) > 0 ? vm.network_interface[0].access_config[0].nat_ip : null
    }
  ]
}
