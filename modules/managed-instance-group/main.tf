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

  # Con un número Terraform fija el tamaño; con null lo deja en manos del autoscaler.
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

  dynamic "auto_healing_policies" {
    # La política es opcional para reutilizar el módulo sin autohealing en otros grupos.
    for_each = var.autohealing == null ? [] : [var.autohealing]

    content {
      health_check      = auto_healing_policies.value.health_check_self_link
      initial_delay_sec = auto_healing_policies.value.initial_delay_sec
    }
  }

  named_port {
    # El balanceador usará este nombre para resolver el puerto HTTP del contenedor.
    name = "http"
    port = 80
  }
}
