// main.tf - имя файла выбрано произвольно, важно только расширение
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }

  required_version = ">= 0.13"
}

// Terraform должен знать ключ, для выполнения команд по API

// Определение переменной, которую нужно будет задать
variable "do_token" {}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_ssh_key" "default" {
  name       = "terraform-test-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "digitalocean_droplet" "default" {
  image  = "ubuntu-22-04-x64"
  name   = "test"
  region = "fra1"
  size   = "s-1vcpu-1gb"

  ssh_keys = [
    digitalocean_ssh_key.default.fingerprint
  ]
}
