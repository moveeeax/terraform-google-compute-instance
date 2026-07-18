output "id" {
  description = "Identifier of the instance."
  value       = google_compute_instance.this.id
}

output "self_link" {
  description = "URI of the instance."
  value       = google_compute_instance.this.self_link
}

output "name" {
  description = "Name of the instance."
  value       = google_compute_instance.this.name
}

output "internal_ip" {
  description = "Internal IP address of the primary network interface."
  value       = google_compute_instance.this.network_interface[0].network_ip
}

output "external_ip" {
  description = "External IP address of the instance, if one was assigned."
  value       = try(google_compute_instance.this.network_interface[0].access_config[0].nat_ip, null)
}
