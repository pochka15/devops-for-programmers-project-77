generate-ssh-keys:
	ssh-keygen -t ed25519 -C "ubuntu@yandex.com" -f ~/.ssh/yandex/id_rsa

generate-yandex-token:
	ansible-playbook ansible/yandex-token.yml

vault-create-password:
	mkdir -p playground; touch playground/vault-password.txt; echo $(password) > playground/vault-password.txt

vault-encrypt:
	ansible-vault encrypt ansible/group_vars/vault.yml  --vault-password-file playground/vault-password.txt

vault-edit:
	ansible-vault edit ansible/group_vars/vault.yml --vault-password-file playground/vault-password.txt

vault-view:
	ansible-vault view ansible/group_vars/vault.yml --vault-password-file playground/vault-password.txt