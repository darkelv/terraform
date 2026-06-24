variable "name" {
  description = "Droplet name."
  type        = string
}

variable "image" {
  description = "Operating system image for the Droplet."
  type        = string
}

variable "region" {
  description = "DigitalOcean region for the Droplet."
  type        = string
}

variable "droplet_size" {
  description = "DigitalOcean Droplet size."
  type        = string
}

variable "vpc_uuid" {
  description = "VPC UUID for the Droplet."
  type        = string
}

variable "ssh_keys" {
  description = "SSH key fingerprints or IDs allowed to access the Droplet."
  type        = list(string)
}
