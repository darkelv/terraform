// main.tf - имя файла выбрано произвольно, важно только расширение
terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
    local = {
      source = "hashicorp/local"
    }
    datadog = {
      source = "DataDog/datadog"
    }
  }

  required_version = ">= 0.13"
}

// Terraform должен знать ключ, для выполнения команд по API

// Определение переменной, которую нужно будет задать
variable "do_token" {}

variable "region" {
  default = "fra1"
}

variable "droplet_size" {
  default = "s-1vcpu-1gb"
}

variable "image" {
  default = "ubuntu-22-04-x64"
}

variable "ssh_public_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "trusted_ssh_sources" {
  default = ["0.0.0.0/0", "::/0"]
}

variable "datadog_api_key" {
  sensitive = true
}

variable "datadog_app_key" {
  sensitive = true
}

variable "datadog_site" {
  default = "datadoghq.eu"
}

variable "datadog_synthetics_location" {
  default = "aws:eu-central-1"
}

locals {
  web_droplets = {
    web1 = "redmine-web-1"
    web2 = "redmine-web-2"
  }
}

provider "digitalocean" {
  token = var.do_token
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.${var.datadog_site}/"
}

resource "digitalocean_ssh_key" "default" {
  name       = "terraform-test-key"
  public_key = file(var.ssh_public_key_path)
}

resource "digitalocean_vpc" "default" {
  name     = "redmine-vpc"
  region   = var.region
  ip_range = "10.10.0.0/16"
}

resource "digitalocean_droplet" "web" {
  for_each = local.web_droplets

  image      = var.image
  name       = each.value
  region     = var.region
  size       = var.droplet_size
  monitoring = true
  vpc_uuid   = digitalocean_vpc.default.id

  ssh_keys = [
    digitalocean_ssh_key.default.fingerprint
  ]
}

resource "digitalocean_droplet" "db" {
  image      = var.image
  name       = "redmine-db-1"
  region     = var.region
  size       = var.droplet_size
  monitoring = true
  vpc_uuid   = digitalocean_vpc.default.id

  ssh_keys = [
    digitalocean_ssh_key.default.fingerprint
  ]
}

resource "digitalocean_loadbalancer" "web" {
  name     = "redmine-lb"
  region   = var.region
  vpc_uuid = digitalocean_vpc.default.id

  droplet_ids = [
    for droplet in digitalocean_droplet.web : droplet.id
  ]

  forwarding_rule {
    entry_protocol  = "http"
    entry_port      = 80
    target_protocol = "http"
    target_port     = 3000
  }

  healthcheck {
    protocol                 = "http"
    port                     = 3000
    path                     = "/"
    check_interval_seconds   = 10
    response_timeout_seconds = 5
    healthy_threshold        = 2
    unhealthy_threshold      = 3
  }
}

resource "datadog_synthetics_test" "redmine" {
  name    = "Redmine load balancer"
  type    = "api"
  subtype = "http"
  status  = "live"

  locations = [var.datadog_synthetics_location]

  request_definition {
    method = "GET"
    url    = "http://${digitalocean_loadbalancer.web.ip}/"
  }

  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "200"
  }

  assertion {
    type     = "body"
    operator = "contains"
    target   = "Redmine"
  }

  options_list {
    tick_every           = 60
    min_location_failed  = 1
    min_failure_duration = 60
  }

  message = "Redmine is unavailable through the DigitalOcean Load Balancer."

  tags = [
    "env:prod",
    "service:redmine",
    "managed_by:terraform"
  ]
}

resource "digitalocean_firewall" "web" {
  name = "redmine-web-firewall"

  droplet_ids = [
    for droplet in digitalocean_droplet.web : droplet.id
  ]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.trusted_ssh_sources
  }

  inbound_rule {
    protocol                  = "tcp"
    port_range                = "3000"
    source_load_balancer_uids = [digitalocean_loadbalancer.web.id]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = var.trusted_ssh_sources
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_firewall" "db" {
  name        = "redmine-db-firewall"
  droplet_ids = [digitalocean_droplet.db.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = var.trusted_ssh_sources
  }

  inbound_rule {
    protocol           = "tcp"
    port_range         = "5432"
    source_droplet_ids = [for droplet in digitalocean_droplet.web : droplet.id]
  }

  inbound_rule {
    protocol         = "icmp"
    source_addresses = var.trusted_ssh_sources
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "all"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "local_file" "ansible_inventory" {
  filename        = "${path.module}/inventory.ini"
  file_permission = "0644"

  content = <<-EOF
[webservers]
%{for name, droplet in digitalocean_droplet.web~}
${name} ansible_host=${droplet.ipv4_address} ansible_host_private=${droplet.ipv4_address_private} ansible_user=app
%{endfor~}

[dbservers]
db1 ansible_host=${digitalocean_droplet.db.ipv4_address} ansible_host_private=${digitalocean_droplet.db.ipv4_address_private} ansible_user=app

[servers:children]
webservers
dbservers
  EOF
}

output "load_balancer_ip" {
  value = digitalocean_loadbalancer.web.ip
}

output "web_public_ips" {
  value = {
    for name, droplet in digitalocean_droplet.web : name => droplet.ipv4_address
  }
}

output "db_public_ip" {
  value = digitalocean_droplet.db.ipv4_address
}

output "ansible_inventory_path" {
  value = local_file.ansible_inventory.filename
}
