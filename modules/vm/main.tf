terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

resource "digitalocean_droplet" "this" {
  image      = var.image
  name       = var.name
  region     = var.region
  size       = var.droplet_size
  monitoring = true
  vpc_uuid   = var.vpc_uuid

  ssh_keys = var.ssh_keys
}
