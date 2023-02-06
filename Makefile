generate-ssh-keys:
	ssh-keygen -t ed25519 -C "ubuntu@yandex.com" -f ~/.ssh/yandex/id_rsa

generate-yandex-token:
	ansible-playbook --vault-password-file playground/vault-password.txt \
	ansible/yandex-token.yml

install-roles:
	ansible-galaxy install -r requirements.yml

vault-create-password:
	mkdir -p playground; \
	touch playground/vault-password.txt; \
	echo $(password) > playground/vault-password.txt

vault-encrypt:
	ansible-vault encrypt ansible/group_vars/$(group)/vault.yml \
	--vault-password-file playground/vault-password.txt

vault-edit:
	ansible-vault edit ansible/group_vars/$(group)/vault.yml \
	--vault-password-file playground/vault-password.txt

vault-view:
	ansible-vault view ansible/group_vars/$(group)/vault.yml \
	--vault-password-file playground/vault-password.txt

terraform-plan-setup:
	ansible-playbook --vault-password-file playground/vault-password.txt \
	--check \
	--tags setup \
	ansible/terraform.yml

terraform-setup:
	ansible-playbook --vault-password-file playground/vault-password.txt \
	--tags setup \
	ansible/terraform.yml

terraform-destroy:
	ansible-playbook --vault-password-file playground/vault-password.txt \
	--tags destroy \
	ansible/terraform.yml

terraform-show-output:
	cd terraform; terraform output -json $(name); cd - > /dev/null

setup-required-packages:
	ansible-playbook -i ansible/inventory.ini \
	--vault-password-file playground/vault-password.txt \
	--tags required \
	--ssh-extra-args "-F ssh_config" \
	ansible/playbook.yml

setup-docker:
	ansible-playbook -i ansible/inventory.ini \
	--vault-password-file playground/vault-password.txt \
	--tags docker \
	--ssh-extra-args "-F ssh_config" \
	ansible/playbook.yml

setup-monitoring:
	ansible-playbook -i ansible/inventory.ini \
	--vault-password-file playground/vault-password.txt \
	--tags monitoring \
	--ssh-extra-args "-F ssh_config" \
	ansible/playbook.yml

setup: setup-required-packages setup-docker setup-monitoring

release:
	ansible-playbook -i ansible/inventory.ini \
	--vault-password-file playground/vault-password.txt \
	--ssh-extra-args "-F ssh_config" \
	ansible/release.yml
	
ssh:
	ssh -F ssh_config $(host)
