# root firewall.tf

# Esta política pertenece a la arquitectura del proyecto y se versiona para que
# cualquier cambio de acceso sea visible y revisable en una pull request.
locals {
  workspace_web_network_tag = "workspace-web-backend"

  iap_source_ranges           = ["35.235.240.0/20"]
  load_balancer_source_ranges = ["35.191.0.0/16", "130.211.0.0/22"]

  firewall_ingress_rules = [
    # IAP permite diagnosticar una VM privada sin asignarle una IP pública.
    {
      name          = "allow-ssh-iap"
      description   = "Acceso SSH seguro mediante Google IAP"
      source_ranges = local.iap_source_ranges
      target_tags   = [local.workspace_web_network_tag]
      protocol      = "tcp"
      ports         = ["22"]
    },

    # HTTPS terminará en el balanceador; las VMs solo reciben HTTP desde Google.
    {
      name          = "allow-load-balancer-to-web"
      description   = "Tráfico HTTP del balanceador y sus health checks"
      source_ranges = local.load_balancer_source_ranges
      target_tags   = [local.workspace_web_network_tag]
      protocol      = "tcp"
      ports         = ["80"]
    }
  ]
}

module "firewall-rules" {
  source       = "./modules/firewall-rules"
  project_id   = var.project_id
  network_name = module.vpc.network_name

  ingress_rules = local.firewall_ingress_rules

  # GCP ya permite la salida de forma implícita; una regla allow no la restringiría ni proporcionaría NAT.
  egress_rules = []
}
