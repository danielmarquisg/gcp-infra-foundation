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

  named_port {
    # El balanceador usará este nombre para resolver el puerto HTTP del contenedor.
    name = "http"
    port = 80
  }
}
