# Hexlet DevOps final project

[![Actions Status](https://github.com/pochka15/devops-for-programmers-project-77/workflows/hexlet-check/badge.svg)](https://github.com/pochka15/devops-for-programmers-project-77/actions)

This is a final Hexlet DevOps project

## Release tutorial

### Step 1. Create accounts and generate necessary keys and passwords

1. Create an account in the Yandex Cloud and install Yandex CLI
2. Generate ssh keys for the Yandex Cloud: `make generate-ssh-keys`
3. Generate yandex token: `make generate-yandex-token`
    1. Note: generated token is saved in the `terraform/secrets.auto.tfvars`. This file is added to the gitignore. This is the only terraform variable which is set in the `tfvars` file. Other variables are passed via ansible.
4. Create ansible vault password: `make vault-create-password password=my_password`
    1. Note: password is saved in the `playground/vault-password.txt`. This file is added to the gitignore

### Step 2. Create terraform infrastructure

1. Set variables in the [all.yml](./ansible/group_vars/all/all.yml) and in the [vault.yml](./ansible/group_vars/all/vault.yml)
    1. Note: to encrypt vault: `make vault-encrypt group=all`
2. Setup terraform infrastructure: `make terraform-setup`

### Step 3. Setup webservers

1. Set webservers variables in the [all.yml](./ansible/group_vars/webservers/all.yml) and in the [vault.yml](./ansible/group_vars/webservers/vault.yml)
    1. Note: to encrypt webservers vault: `make vault-encrypt group=webservers`
    2. Also: to get terraform output: `make -s terraform-show-output name=pg_host` ("name" parameter is optional)
2. `make setup`

### Step 3. Release application

1. `make release`

## Test deployed application

Application will be deployed at `http://your-domain`. I've deployed it to [pochka15.click](https://pochka15.click).
To enable HTTPS see the "Enable HTTPS" section

## Connect to webserver via SSH

`make ssh host=web2`

## Enable HTTPS

When creating terraform infrastructure it's automatically created a certificate for the domain you specified. See the [domain.tf](./terraform/domain.tf) for details. But in order to enable HTTPS you have to wait until certificate status becomes "ISSUED". When it's issued, you have to go through the next steps manually 😕:

1. Destroy these resources (Note: you can just comment the resource blocks and apply terraform)
   1. `yandex_alb_load_balancer.hexlet-balancer` from the [balancer.tf](./terraform/balancer.tf)
   2. `yandex_dns_recordset.balancer-record` from the [domain.tf](./terraform/domain.tf)
2. Create resources again
   1. `yandex_alb_load_balancer.hexlet-balancer` from the [balancer.tf](./terraform/balancer.tf) but this time uncomment `HTTPS listener block` and comment `HTTP listener block`
   2. `yandex_dns_recordset.balancer-record` from the [domain.tf](./terraform/domain.tf)

What this does is it destroys and creates balancer that listens on port 443 instead of port 80. For now I couldn't find a better way to automate it. Because when I try to change listener without destroying it I get this error: "Either external ipv4 address or internal ipv4 address or external ipv6 address should be specified for the HTTP route".
