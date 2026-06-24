# Terraform + Ansible Redmine

Проект создает инфраструктуру в DigitalOcean через Terraform и разворачивает Redmine через Ansible.

Terraform создает:

- 2 web-сервера для Redmine
- 1 db-сервер для PostgreSQL
- DigitalOcean Load Balancer
- VPC и firewall
- Datadog Synthetic test для проверки Redmine через Load Balancer
- `inventory.ini` для Ansible в этой же папке

Ansible разворачивает:

- PostgreSQL container на db-сервере
- Redmine container на двух web-серверах
- Datadog Agent на web-серверах

Секреты нужно указать в `secrets.auto.tfvars`:

```hcl
do_token = "<тут секретный ключ DigitalOcean>"

datadog_api_key = "<Datadog API key>"
datadog_app_key = "<Datadog application key>"
```

`datadog_api_key` уже есть в Ansible Vault как `vault_datadog_api_key`.
Посмотреть его можно командой `make vault_view`.
Для Terraform также нужен `datadog_app_key`; его нужно создать в Datadog и добавить сюда же.

Команды:

```bash
make init
make infra
make create_user
make prepare
make deploy
```

IP балансировщика Terraform покажет в output `load_balancer_ip`.
Datadog Synthetic test будет проверять `http://<load_balancer_ip>/`.

Datadog Agent можно поставить отдельно:

```bash
make datadog
```

Удаление инфраструктуры:

```bash
make destroy
```
