output "id" {
  description = "Droplet ID."
  value       = digitalocean_droplet.this.id
}

output "ipv4_address" {
  description = "Public IPv4 address."
  value       = digitalocean_droplet.this.ipv4_address
}

output "ipv4_address_private" {
  description = "Private IPv4 address."
  value       = digitalocean_droplet.this.ipv4_address_private
}
