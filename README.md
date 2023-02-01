# Hexlet DevOps final project

[![Actions Status](https://github.com/pochka15/devops-for-programmers-project-77/workflows/hexlet-check/badge.svg)](https://github.com/pochka15/devops-for-programmers-project-77/actions)

This is a final Hexlet DevOps project

## Setup

1. Create an account in the Yandex Cloud and install Yandex CLI
2. Generate ssh keys for the Yandex Cloud: `make generate-ssh-keys`
3. Generate yandex token: `make generate-yandex-token`
    1. Note: generated token is stored in `terraform/secrets.auto.tfvars`. This file is added to the gitignore. This is the only terraform variable which is set in the `tfvars` file. Other variables are passed via ansible.
4. Create ansible vault password: `make vault-create-password password=my_password`
    1. Note: it's saved in the `playground/vault-password.txt`. This file is added to the gitignore
5. Set variables in the [all.yml](./ansible/group_vars/all/all.yml) and in the [vault.yml](./ansible/group_vars/all/vault.yml)
    1. Note: to encrypt vault: `make vault-encrypt group=all`
6. Setup terraform infrastructure: `make terraform-setup`
7. Set webservers variables in the [all.yml](./ansible/group_vars/webservers/all.yml) and in the [vault.yml](./ansible/group_vars/webservers/vault.yml)
    1. Note: to encrypt webservers vault: `make vault-encrypt group=webservers`
    2. Also: to get terraform output: `make -s terraform-show-output name=pg_host` ("name" parameter is optional)
8. Setup webservers: `make setup`
9. Release application: `make release`

## Deployed application

Application will be deployed at `http://your-domain`. I've deployed it to [pochka15.click](https://pochka15.click)

## SSH

- To connect to the virtual machine "web1": `make ssh host=web2`

## Enable HTTPS

When creating terraform infrastructure it's automatically created a certificate for the domain you specified. See the [domain.tf](./terraform/domain.tf) for details. But in order to enable HTTPS you have to wait until certificate status becomes "ISSUED". When it's issued, sadly you have to go through the next steps manually (see the):

1. Destroy these resources (Note: you can just comment the resource blocks and apply terraform)
   1. `yandex_dns_recordset.balancer-record` resource from the [domain.tf](./terraform/domain.tf)
   2. `yandex_alb_load_balancer.hexlet-balancer` resource from the [balancer.tf](./terraform/balancer.tf)
2. Create resources again
   1. `yandex_dns_recordset.balancer-record` resource from the [domain.tf](./terraform/domain.tf)
   2. `yandex_alb_load_balancer.hexlet-balancer` resource but this time uncomment `HTTPS listener block` and comment `HTTP listener block` in the [balancer.tf](./terraform/balancer.tf)

What this does is it destroys and creates balancer that listens on port 443 instead of port 80. For now I couldn't find a better way to automate it. Because I cannot subsitute balancer listeners. Terraform apply gives an error when I try to change listeners in-place: "Either external ipv4 address or internal ipv4 address or external ipv6 address should be specified for the HTTP route"
