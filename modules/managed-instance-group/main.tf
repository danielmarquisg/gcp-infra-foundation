# modules/managed-instance-group/main.tf

resource "google_compute_instance_group_manager" "web" {
  project            = var.project_id
  zone               = var.zone
  name               = var.name
  base_instance_name = var.base_instance_name

  version {
    # Al cambiar la plantilla, las nuevas VMs nacerán con la versión indicada aquí.
    instance_template = var.instance_template_self_link
  }

  # Número de instancias que mantiene el grupo.
  target_size = var.target_size

  update_policy {
    # Sustituye las VMs existentes cuando cambia la plantilla, sin actualizarlas a mano.
    type               = "PROACTIVE"
    minimal_action     = "REPLACE"
    replacement_method = "SUBSTITUTE"

    # Crea una VM adicional antes de retirar la anterior.
    max_surge_fixed       = 1
    max_unavailable_fixed = 0
  }

  named_port {
    # El balanceador usará este nombre para resolver el puerto HTTP del contenedor.
    name = "http"
    port = 80
  }
}
