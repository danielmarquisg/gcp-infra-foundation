# modules/instances/main.tf

resource "google_compute_instance" "vm" {
  count        = var.instance_count
  name         = "${var.name_prefix}-${format("%02d", count.index + 1)}"
  machine_type = var.machine_type
  zone         = var.zone
  project      = var.project_id
  tags         = var.tags

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    subnetwork = var.subnet_name

    # Lógica de IP Publica
    dynamic "access_config" {
      for_each = var.enable_public_ip ? [1] : []
      content {
        # Vacio = IP Efimera automatica
      }
    }
  }

  metadata = {
    enable-oslogin = "TRUE"
  }
}
