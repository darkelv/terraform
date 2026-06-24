# VM Module

Модуль создает один DigitalOcean Droplet.

Пример использования:

```hcl
module "web" {
  source = "./modules/vm"

  name         = "redmine-web-1"
  image        = var.image
  region       = var.region
  droplet_size = var.droplet_size
  vpc_uuid     = digitalocean_vpc.default.id
  ssh_keys     = [digitalocean_ssh_key.default.fingerprint]
}
```

Входные переменные:

- `name` - имя сервера
- `image` - образ операционной системы
- `region` - регион DigitalOcean
- `droplet_size` - размер Droplet
- `vpc_uuid` - идентификатор VPC
- `ssh_keys` - список SSH-ключей

Выходные данные:

- `id` - ID сервера
- `ipv4_address` - публичный IPv4 адрес
- `ipv4_address_private` - приватный IPv4 адрес
