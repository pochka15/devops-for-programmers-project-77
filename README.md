# Hexlet DevOps final project

[![Actions Status](https://github.com/pochka15/devops-for-programmers-project-77/workflows/hexlet-check/badge.svg)](https://github.com/pochka15/devops-for-programmers-project-77/actions)

This is a final Hexlet DevOps project

## Setup

- Create an account in the Yandex Cloud and install Yandex CLI
- Create an account in the Datadog
- Generate ssh keys for the Yandex Cloud: `make generate-ssh-keys`
- Generate yandex token: `make generate-yandex-token`
  - Note: generated token is stored in `terraform/secrets.auto.tfvars`. This file is added to the gitignore. This is the only terraform variable which is set in the `tfvars` file. Other variables are passed via ansible.
- Create ansible vault password: `make vault-create-password password=my_password`
  - Note: it's saved in the `playground/vault-password.txt`. This file is added to the gitignore
- Set variables in the [all.yml](./ansible/group_vars/all/all.yml) and in the [vault.yml](./ansible/group_vars/all/vault.yml)
  - Note: to encrypt vault: `make vault-encrypt group=all`
- Setup terraform infrastructure: `make terraform-setup`
- Set webservers variables in the [all.yml](./ansible/group_vars/webservers/all.yml) and in the [vault.yml](./ansible/group_vars/webservers/vault.yml)
  - Note: to encrypt vault: `make vault-encrypt group=webservers`
- Setup webservers: `make setup`
- Release application: `make release`

## Deployed application

Application is currently deployed at [http://pochka15.click](http://pochka15.click)

## SSH

- To connect to the virtual machine "web1": `make ssh host=web2`
