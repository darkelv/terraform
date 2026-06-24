variable "do_token" {
  description = "DigitalOcean API token."
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region for all resources."
  type        = string
  default     = "fra1"
}

variable "droplet_size" {
  description = "DigitalOcean Droplet size."
  type        = string
  default     = "s-1vcpu-1gb"
}

variable "image" {
  description = "Operating system image for Droplets."
  type        = string
  default     = "ubuntu-22-04-x64"
}

variable "ssh_public_key_path" {
  description = "Path to the public SSH key."
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "trusted_ssh_sources" {
  description = "CIDR blocks allowed to connect to servers by SSH."
  type        = list(string)
  default     = ["0.0.0.0/0", "::/0"]
}

variable "datadog_api_key" {
  description = "Datadog API key."
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog application key."
  type        = string
  sensitive   = true
}

variable "datadog_site" {
  description = "Datadog site."
  type        = string
  default     = "datadoghq.eu"
}

variable "datadog_synthetics_location" {
  description = "Datadog Synthetic test location."
  type        = string
  default     = "aws:eu-central-1"
}
