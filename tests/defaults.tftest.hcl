# Test-only requirement: `mock_provider` needs Terraform >= 1.7 / OpenTofu >= 1.7.
# The module itself still supports >= 1.5, so versions.tf is deliberately not bumped.

mock_provider "google" {}

variables {
  project_id = "example-project"
  name       = "unit-test"
  zone       = "us-central1-a"
}

run "defaults_are_safe" {
  command = plan

  assert {
    condition     = length(google_compute_instance.this.network_interface[0].access_config) == 0
    error_message = "The module must not attach an external IP by default; an empty access_config block assigns an ephemeral public address."
  }

  assert {
    condition     = google_compute_instance.this.metadata["enable-oslogin"] == "TRUE"
    error_message = "OS Login must be enabled by default so SSH access is governed by IAM rather than metadata SSH keys."
  }

  assert {
    condition     = google_compute_instance.this.metadata["serial-port-enable"] == "FALSE"
    error_message = "Interactive serial console access must be disabled explicitly, overriding any project-wide enablement."
  }

  assert {
    condition     = google_compute_instance.this.shielded_instance_config[0].enable_secure_boot == true
    error_message = "Secure Boot must be enabled by default."
  }

  assert {
    condition     = google_compute_instance.this.shielded_instance_config[0].enable_vtpm == true
    error_message = "The virtual TPM must be enabled by default."
  }

  assert {
    condition     = google_compute_instance.this.shielded_instance_config[0].enable_integrity_monitoring == true
    error_message = "Integrity monitoring must be enabled by default."
  }

  assert {
    condition     = length(google_compute_instance.this.service_account) == 0
    error_message = "No service account may be attached by default; the Compute Engine default service account holds Editor on the whole project."
  }

  assert {
    condition     = google_compute_instance.this.allow_stopping_for_update == false
    error_message = "Terraform must not be allowed to stop a running instance unless the consumer opts in."
  }
}

run "external_ip_is_opt_in" {
  command = plan

  variables {
    assign_external_ip = true
  }

  assert {
    condition     = length(google_compute_instance.this.network_interface[0].access_config) == 1
    error_message = "assign_external_ip = true must produce exactly one access_config block."
  }
}

run "user_metadata_wins_over_hardening_defaults" {
  command = plan

  variables {
    metadata = {
      enable-oslogin = "FALSE"
      owner          = "platform"
    }
  }

  assert {
    condition     = google_compute_instance.this.metadata["enable-oslogin"] == "FALSE"
    error_message = "An explicit metadata key must override the module's hardening default."
  }

  assert {
    condition     = google_compute_instance.this.metadata["owner"] == "platform"
    error_message = "User-supplied metadata keys must be preserved."
  }

  assert {
    condition     = google_compute_instance.this.metadata["serial-port-enable"] == "FALSE"
    error_message = "Overriding one hardening key must not drop the others."
  }
}

run "service_account_scopes_default_to_cloud_platform" {
  command = plan

  variables {
    service_account = {
      email = "app@example-project.iam.gserviceaccount.com"
    }
  }

  assert {
    condition     = google_compute_instance.this.service_account[0].email == "app@example-project.iam.gserviceaccount.com"
    error_message = "The supplied service account email must be attached to the instance."
  }

  assert {
    condition     = google_compute_instance.this.service_account[0].scopes == toset(["https://www.googleapis.com/auth/cloud-platform"])
    error_message = "Scopes must default to cloud-platform, with access narrowed through IAM roles on the service account."
  }
}

run "shielded_vm_can_be_disabled_for_non_uefi_images" {
  command = plan

  variables {
    enable_shielded_vm = false
  }

  assert {
    condition     = length(google_compute_instance.this.shielded_instance_config) == 0
    error_message = "enable_shielded_vm = false must omit the shielded_instance_config block entirely."
  }
}

run "rejects_undersized_boot_disk" {
  command = plan

  variables {
    boot_disk_size = 5
  }

  expect_failures = [var.boot_disk_size]
}

run "rejects_startup_script_defined_twice" {
  command = plan

  variables {
    metadata_startup_script = "#!/bin/bash\necho hello"
    metadata = {
      startup-script = "#!/bin/bash\necho conflict"
    }
  }

  expect_failures = [google_compute_instance.this]
}
