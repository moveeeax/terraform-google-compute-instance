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
  description = "Metadata key/value pairs made available to the instance."
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Labels applied to the instance."
  type        = map(string)
  default     = {}
}
