# Hexlet DevOps final project

[![Actions Status](https://github.com/pochka15/devops-for-programmers-project-77/workflows/hexlet-check/badge.svg)](https://github.com/pochka15/devops-for-programmers-project-77/actions)

This is a final Hexlet DevOps project

## Setup

- Create an account in the Yandex Cloud and install Yandex CLI
- Generate ssh keys for the Yandex Cloud `make generate-ssh-keys`
- Create vault password: `make vault-create-password password=my_password`
- Setup yandex token: `make generate-yandex-token vault-encrypt`
- Set variables in [all.yml](./ansible/group_vars/all.yml). To edit vault variables: `make vault-edit`
- Setup terraform infrastructure: `make terraform-setup`
