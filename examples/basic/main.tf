terraform {
  required_version = ">= 1.5"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

module "instance" {
  source = "../.."

  project_id   = var.project_id
  name         = "example-instance"
  zone         = "${var.region}-a"
  machine_type = "e2-small"

  labels = {
    environment = "sandbox"
    managed_by  = "terraform"
  }
}

variable "project_id" {
  description = "Project ID to deploy the example instance into."
  type        = string
}

variable "region" {
  description = "Region for the google provider; zone is derived as region-a."
  type        = string
  default     = "us-central1"
}

output "instance_id" {
  value = module.instance.id
}
