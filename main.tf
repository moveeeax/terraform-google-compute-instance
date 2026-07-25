locals {
  # Hardening metadata applied to every instance. Keys passed explicitly through
  # `var.metadata` take precedence, so a consumer that already manages these keys
  # keeps its current behaviour.
  hardening_metadata = {
    # OS Login binds SSH access to IAM instead of project/instance SSH keys.
    enable-oslogin = var.enable_oslogin ? "TRUE" : "FALSE"
    # Set explicitly so a project-wide `serial-port-enable=TRUE` cannot silently
    # open an interactive console on this instance.
    serial-port-enable = var.enable_serial_port ? "TRUE" : "FALSE"
  }
}

resource "google_compute_instance" "this" {
  project      = var.project_id
  name         = var.name
  zone         = var.zone
  machine_type = var.machine_type
  tags         = var.tags
  metadata     = merge(local.hardening_metadata, var.metadata)
  labels       = var.labels

  metadata_startup_script   = var.metadata_startup_script
  allow_stopping_for_update = var.allow_stopping_for_update

  boot_disk {
    kms_key_self_link = var.boot_disk_kms_key_self_link

    initialize_params {
      image = var.image
      size  = var.boot_disk_size
    }
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetwork

    dynamic "access_config" {
      for_each = var.assign_external_ip ? [1] : []
      content {}
    }
  }

  # Omitted entirely when `var.service_account` is null, which leaves the
  # instance with no service account attached rather than the Compute Engine
  # default service account.
  dynamic "service_account" {
    for_each = var.service_account == null ? [] : [var.service_account]

    content {
      email  = service_account.value.email
      scopes = service_account.value.scopes
    }
  }

  dynamic "shielded_instance_config" {
    for_each = var.enable_shielded_vm ? [1] : []

    content {
      enable_secure_boot          = var.enable_secure_boot
      enable_vtpm                 = var.enable_vtpm
      enable_integrity_monitoring = var.enable_integrity_monitoring
    }
  }

  lifecycle {
    precondition {
      condition     = var.metadata_startup_script == null || !contains(keys(var.metadata), "startup-script")
      error_message = "Set either metadata_startup_script or metadata[\"startup-script\"], not both: the google provider rejects an instance that defines the startup script twice."
    }
  }
}
