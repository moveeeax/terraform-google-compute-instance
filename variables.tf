variable "project_id" {
  description = "ID of the project in which to create the instance."
  type        = string
}

variable "name" {
  description = "Name of the compute instance."
  type        = string
}

variable "zone" {
  description = "Zone in which to create the instance."
  type        = string
}

variable "machine_type" {
  description = "Machine type for the instance."
  type        = string
  default     = "e2-medium"
}

variable "image" {
  description = "Boot disk image for the instance."
  type        = string
  default     = "debian-cloud/debian-12"
}

variable "boot_disk_size" {
  description = "Size of the boot disk in GB."
  type        = number
  default     = 20

  validation {
    condition     = var.boot_disk_size >= 10
    error_message = "boot_disk_size must be at least 10 GB."
  }
}

variable "network" {
  description = "Self link or name of the network to attach the instance to."
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "Self link or name of the subnetwork to attach the instance to."
  type        = string
  default     = null
}

variable "assign_external_ip" {
  description = "Whether to assign an ephemeral external IP to the instance."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Network tags applied to the instance."
  type        = list(string)
  default     = []
}

variable "metadata" {
  description = <<-EOT
    Metadata key/value pairs made available to the instance. Keys set here win
    over the module's hardening defaults (`enable-oslogin`, `serial-port-enable`),
    so use this to override them deliberately. Instance metadata is readable by
    every process on the VM through the metadata server and is stored
    unencrypted, so do not put secrets here.
  EOT
  type        = map(string)
  default     = {}
}

variable "metadata_startup_script" {
  description = <<-EOT
    Startup script run on boot, written to the `startup-script` metadata key.
    Marked sensitive so that it is redacted from plan output and CI logs,
    because bootstrap scripts are a common place for credentials to end up.
    Metadata is stored unencrypted and is readable from the metadata server by
    anything running on the instance, so fetch real secrets from Secret Manager
    at boot instead of embedding them. Mutually exclusive with
    `metadata["startup-script"]`.
  EOT
  type        = string
  default     = null
  sensitive   = true
}

variable "labels" {
  description = "Labels applied to the instance."
  type        = map(string)
  default     = {}
}

variable "enable_oslogin" {
  description = <<-EOT
    Enable OS Login on the instance, which authorises SSH through IAM rather
    than project-wide or instance-level SSH keys and gives centralised access
    revocation and audit logging.
  EOT
  type        = bool
  default     = true
}

variable "enable_serial_port" {
  description = <<-EOT
    Enable interactive serial console access. Left off by default and written
    explicitly so that a project-wide `serial-port-enable=TRUE` cannot enable it
    for this instance; the serial console bypasses firewall rules and OS Login.
  EOT
  type        = bool
  default     = false
}

variable "enable_shielded_vm" {
  description = <<-EOT
    Emit a `shielded_instance_config` block. Requires a UEFI-enabled image (all
    current Google-provided images qualify). Set to false for custom images
    without UEFI support, which the API rejects when the block is present.
  EOT
  type        = bool
  default     = true
}

variable "enable_secure_boot" {
  description = <<-EOT
    Require Secure Boot, so the instance refuses to boot unsigned kernels,
    drivers or bootloaders. Disable it if the workload loads out-of-tree kernel
    modules that are not signed by a trusted key.
  EOT
  type        = bool
  default     = true
}

variable "enable_vtpm" {
  description = "Enable the virtual Trusted Platform Module, which underpins measured boot and integrity monitoring."
  type        = bool
  default     = true
}

variable "enable_integrity_monitoring" {
  description = "Enable integrity monitoring, which compares the boot measurements of each boot against a trusted baseline."
  type        = bool
  default     = true
}

variable "service_account" {
  description = <<-EOT
    Service account to attach to the instance. Leave null to attach none, which
    is the safe default: attaching the Compute Engine default service account
    grants the instance the Editor role on the whole project. When you do attach
    one, use a dedicated account with only the IAM roles the workload needs.
    Scopes default to `cloud-platform` because Google now recommends controlling
    access with IAM roles on the service account rather than with legacy scopes.
  EOT
  type = object({
    email  = string
    scopes = optional(list(string), ["https://www.googleapis.com/auth/cloud-platform"])
  })
  default = null
}

variable "boot_disk_kms_key_self_link" {
  description = <<-EOT
    Self link of a Cloud KMS key used to encrypt the boot disk. Leave null to
    use Google-managed encryption keys, which still encrypt the disk at rest;
    set it when a customer-managed key is required.
  EOT
  type        = string
  default     = null
}

variable "allow_stopping_for_update" {
  description = <<-EOT
    Allow Terraform to stop the instance to apply changes that Compute Engine
    only accepts on a stopped VM, such as machine type or Shielded VM settings.
    Leave false to make Terraform fail loudly instead of causing an unplanned
    outage.
  EOT
  type        = bool
  default     = false
}
