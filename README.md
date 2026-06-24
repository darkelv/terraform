# Terraform DigitalOcean Redmine

Terraform создает:

- 2 web-сервера для Redmine
- 1 db-сервер для PostgreSQL
- DigitalOcean Load Balancer
- VPC и firewall
- `inventory.ini` для Ansible-проекта

Ключ DigitalOcean нужно указать в `secrets.auto.tfvars`:

```hcl
do_token = "<тут секретный ключ DigitalOcean>"
```

Команды:

```bash
terraform init
terraform apply
cd /Users/darkelv/ansible/devops-for-developers-project-76
make create_user
make prepare
make deploy
```

IP балансировщика Terraform покажет в output `load_balancer_ip`.

Удаление инфраструктуры:

```bash
terraform destroy
```
