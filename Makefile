generate-ssh-keys:
	ssh-keygen -t ed25519 -C "ubuntu@yandex.com" -f ~/.ssh/yandex/id_rsa

generate-yandex-token:
	ansible-playbook --vault-password-file playground/vault-password.txt \
	ansible/yandex-token.yml

install_roles:
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

terraform-setup:
	ansible-playbook --vault-password-file playground/vault-password.txt \
	ansible/terraform-setup.yml

terraform-show-output:
	cd terraform; terraform output $(name); cd - > /dev/null

setup_required_packages:
	ansible-playbook -i ansible/inventory.ini \
	--vault-password-file playground/vault-password.txt \
	--tags required \
	--ssh-extra-args "-F ssh_config" \
	ansible/playbook.yml

setup_docker:
	ansible-playbook -i ansible/inventory.ini \
	--vault-password-file playground/vault-password.txt \
	--tags docker \
	--ssh-extra-args "-F ssh_config" \
	ansible/playbook.yml

setup: setup_required_packages setup_docker

release:
	ansible-playbook -i ansible/inventory.ini \
	--vault-password-file playground/vault-password.txt \
	--ssh-extra-args "-F ssh_config" \
	ansible/release.yml
	
ssh:
	ssh -F ssh_config $(host)
