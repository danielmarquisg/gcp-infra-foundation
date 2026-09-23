# modules/instance-template/main.tf

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
    source_image = var.source_image
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
    # Centraliza el acceso SSH en IAM y evita repartir claves entre VMs reemplazables.
    "enable-oslogin" = "TRUE"

    # COS interpreta este contenido en cada arranque para recuperar el estado deseado.
    "user-data" = templatefile("${path.module}/cloud-init.yaml.tftpl", {
      container_image         = var.container_image
      container_registry_host = local.container_registry_host
    })
  }

  shielded_instance_config {
    # Solo permite arrancar componentes firmados y de confianza.
    enable_secure_boot = true

    # El TPM virtual conserva las mediciones utilizadas para verificar el arranque.
    enable_vtpm = true

    # Informa si el estado del arranque difiere de la referencia esperada.
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
