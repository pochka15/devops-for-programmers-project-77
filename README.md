# Hexlet DevOps final project

[![Actions Status](https://github.com/pochka15/devops-for-programmers-project-77/workflows/hexlet-check/badge.svg)](https://github.com/pochka15/devops-for-programmers-project-77/actions)

This is a final Hexlet DevOps project

## Setup

- Create an account in the Yandex Cloud and install Yandex CLI
- Generate ssh keys for the Yandex Cloud: `make generate-ssh-keys`
- Generate yandex token: `make generate-yandex-token`
  - Note: generated token is stored in `terraform/secrets.auto.tfvars`. This file is added to the gitignore. This is the only terraform variable which is set in the `tfvars` file. Other variables are passed via ansible.
- Create ansible vault password: `make vault-create-password password=my_password`
  - Note: it's saved in the `playground/vault-password.txt`. This file is added to the gitignore
- Set variables in [all.yml](./ansible/group_vars/all/all.yml) and in the [vault.yml](./ansible/group_vars/all/vault.yml)
  - Note: to encrypt vault: `make vault-encrypt`
- Setup terraform infrastructure: `make terraform-setup`
- Setup webservers: `make setup`

## SSH

- To connect to the virtual machine "web1": `make ssh host=web2`
