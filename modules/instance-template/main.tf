# modules/instance-template/main.tf

# La familia se resuelve a una imagen concreta de Container-Optimized OS al crear la plantilla.
data "google_compute_image" "cos" {
  project = "cos-cloud"
  family  = "cos-stable"
}

locals {
  # El helper de credenciales necesita conocer el dominio del registro antes de descargar la imagen.
  container_registry_host = split("/", var.container_image)[0]
}

resource "google_compute_instance_template" "web" {
  project      = var.project_id
  name_prefix  = "${var.name_prefix}-"
  description  = "Plantilla inmutable para las instancias de Workspace Web"
  machine_type = var.machine_type
  tags         = sort(tolist(var.network_tags))

  disk {
    source_image = data.google_compute_image.cos.self_link
    auto_delete  = true
    boot         = true
    disk_size_gb = var.boot_disk_size_gb
    disk_type    = "pd-balanced"
  }

  network_interface {
    subnetwork = var.subnetwork_self_link

    # Sin access_config: las instancias creadas desde la plantilla no reciben IP pública.
  }

  service_account {
    email = var.service_account_email

    # El scope permite solicitar tokens; los permisos efectivos los limita IAM.
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  metadata = {
    "enable-oslogin" = "TRUE"
    "user-data" = templatefile("${path.module}/cloud-init.yaml.tftpl", {
      container_image         = var.container_image
      container_registry_host = local.container_registry_host
    })
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  scheduling {
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
    provisioning_model  = "STANDARD"
  }

  lifecycle {
    # Una plantilla utilizada por un MIG se reemplaza creando primero su nueva versión.
    create_before_destroy = true
  }
}
