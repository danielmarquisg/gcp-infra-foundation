# modules/instances/main.tf

resource "google_compute_instance" "vm" {
  # count identifica las réplicas por índice; al reducirlo se retiran los índices más altos.
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
    subnetwork = var.subnet_self_link

    # Sin access_config la VM conserva su IP interna, pero no recibe una IP pública IPv4.
    dynamic "access_config" {
      # [1] genera un bloque y [] ninguno; el 1 solo sirve para indicar una repetición.
      for_each = var.enable_public_ip ? [1] : []
      content {
        # Dejamos nat_ip sin definir porque aquí no necesitamos reservar una dirección fija.
        # GCP asigna una IP pública efímera: puede cambiar al detener y volver a iniciar la VM.
      }
    }
  }

  metadata = {
    # OS Login gestiona el acceso SSH mediante IAM; los permisos se conceden por separado.
    enable-oslogin = "TRUE"
  }
}
