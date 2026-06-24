VAULT_PASSWORD_FILE ?= .vault_password
PLAYBOOK = ansible-playbook --vault-password-file $(VAULT_PASSWORD_FILE) -i inventory.ini

.PHONY: init infra destroy install_requirements create_user prepare deploy datadog vault_edit vault_view

init:
	terraform init

infra:
	terraform apply

destroy:
	terraform destroy

install_requirements:
	ansible-galaxy install -r requirements.yml

create_user:
	$(PLAYBOOK) create_user.yml -u root

prepare: install_requirements
	$(PLAYBOOK) playbook.yml --tags prepare

deploy:
	$(PLAYBOOK) playbook.yml --tags deploy

datadog: install_requirements
	$(PLAYBOOK) playbook.yml --tags datadog

vault_edit:
	ansible-vault edit group_vars/all/vault.yml --vault-password-file $(VAULT_PASSWORD_FILE)

vault_view:
	ansible-vault view group_vars/all/vault.yml --vault-password-file $(VAULT_PASSWORD_FILE)
