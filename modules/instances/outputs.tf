# modules/instances/outputs.tf

output "instances_info" {
  description = "Lista de nombres e IPs de las maquinas creadas"
  value = [
    for vm in google_compute_instance.vm : {
      name        = vm.name
      internal_ip = vm.network_interface.0.network_ip
      public_ip   = length(vm.network_interface.0.access_config) > 0 ? vm.network_interface.0.access_config.0.nat_ip : "Sin IP Publica"
    }
  ]
}