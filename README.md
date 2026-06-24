# Terraform + Ansible Redmine

Проект создает инфраструктуру в DigitalOcean через Terraform и разворачивает Redmine через Ansible.

Terraform создает:

- 2 web-сервера для Redmine
- 1 db-сервер для PostgreSQL
- DigitalOcean Load Balancer
- VPC и firewall
- Datadog Synthetic test для проверки Redmine через Load Balancer
- `inventory.ini` для Ansible в этой же папке

Виртуальные машины создаются через локальный модуль `modules/vm`.
Краткая документация по модулю лежит в [`modules/vm/README.md`](modules/vm/README.md).

Ansible разворачивает:

- PostgreSQL container на db-сервере
- Redmine container на двух web-серверах
- Datadog Agent на web-серверах

Секреты нужно указать в локальном файле `secret.auto.tfvars`:

```hcl
do_token = "<тут секретный ключ DigitalOcean>"

datadog_api_key = "<Datadog API key>"
datadog_app_key = "<Datadog application key>"
```

Этот файл не нужно коммитить. Он попадает под правила `.gitignore`: `secret.*` и `*.auto.tfvars`.
Terraform загрузит `secret.auto.tfvars` автоматически.

`datadog_api_key` уже есть в Ansible Vault как `vault_datadog_api_key`.
Посмотреть его можно командой `make vault_view`.
Для Terraform также нужен `datadog_app_key`; его нужно создать в Datadog и добавить сюда же.

Секреты также можно передать через переменные окружения:

```bash
export TF_VAR_do_token="<тут секретный ключ DigitalOcean>"
export TF_VAR_datadog_api_key="<Datadog API key>"
export TF_VAR_datadog_app_key="<Datadog application key>"
```

Файлы состояния `terraform.tfstate` и `terraform.tfstate.backup` тоже игнорируются, потому что Terraform может хранить в них чувствительные данные.

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
