# Hexlet DevOps final project

[![Actions Status](https://github.com/pochka15/devops-for-programmers-project-77/workflows/hexlet-check/badge.svg)](https://github.com/pochka15/devops-for-programmers-project-77/actions)

This is a final Hexlet DevOps project

## Release tutorial

Note: See the "Make commands" section. You can find helpful commands there

### Step 1. Setup Yandex Cloud

1. Create an account in the Yandex Cloud and install Yandex CLI
2. Create [S3 bucket](https://cloud.yandex.com/en/docs/storage/operations/buckets/create). Terraform state is saved to this bucket.
3. Create a [service account](https://cloud.yandex.com/en/docs/iam/operations/sa/create) with [the editor](https://cloud.yandex.com/en/docs/iam/concepts/access-control/roles#editor) role. Terraform state is edited by this account.
4. Generate [static access keys](https://cloud.yandex.com/en/docs/iam/operations/sa/create-access-key) for the service account created in the previous step.
   1. Note: save the ID key_id and secret key to some temporary file. You will not be able to get the key value again

### Step 2. Setup DataDog monitoring

1. Create a DataDog account
2. Save api_token and app_token to some temporary file

### Step 3. Setup Ansible

1. Install Ansible. Preferrably version >= core 2.14.1
2. `make install-roles`

### Step 4. Create necessary keys and passwords

1. Generate ssh keys for the Yandex Cloud: `make generate-ssh-keys`
2. Generate yandex token: `make generate-yandex-token`
    1. Note: generated token is saved in the `terraform/secrets.auto.tfvars`. This file is added to the gitignore. This is the only terraform variable which is set in the `tfvars` file. Other variables are passed via ansible.
3. Create ansible vault password: `make vault-create-password password=my_password`
    1. Note: password is saved in the `playground/vault-password.txt`. This file is added to the gitignore

### Step 5. Create terraform infrastructure

1. Set variables in the [vars.yml](./ansible/group_vars/all/vars.yml)
   1. Note: PostgreSQL password must be between 8 and 128 characters long
2. Setup terraform infrastructure: `make terraform-setup`
   1. Note: after this step, it's automatically created a webservers vault in the `playground/vault.yml`. This file is added to the gitignore

### Step 6. Setup webservers

1. Set variables in the [vars.yml](./ansible/group_vars/webservers/vars.yml)
   1. Note: you can copy-paste generated `playground/vault.yml` from the previous step and edit it if necessary
2. `make setup`

### Step 7. Release application

1. `make release`

## Test deployed application

Application will be deployed at `http://your-domain`. I've deployed it to [pochka15.click](https://pochka15.click).
To enable HTTPS see the "Enable HTTPS" section

## Enable HTTPS

When creating terraform infrastructure it's automatically created a certificate for the domain you specified. See the [domain.tf](./terraform/domain.tf) for details. But in order to enable HTTPS you have to wait until certificate status becomes "ISSUED". When it's issued, you have two options. First is to go and change balancer listener manually in the Yandex Cloud console. But this can lead to incorrect terraform state synchronization. Second is to go through the next steps manually 😕:

1. Destroy these resources (Note: you can just comment the resource blocks and apply terraform)
   1. `yandex_alb_load_balancer.hexlet-balancer` from the [balancer.tf](./terraform/balancer.tf)
   2. `yandex_dns_recordset.balancer-record` from the [domain.tf](./terraform/domain.tf)
2. Create resources again
   1. `yandex_alb_load_balancer.hexlet-balancer` from the [balancer.tf](./terraform/balancer.tf) but this time uncomment `HTTPS listener block` and comment `HTTP listener block`
   2. `yandex_dns_recordset.balancer-record` from the [domain.tf](./terraform/domain.tf)

What this does is it destroys and creates balancer that listens on port 443 instead of port 80. For now I couldn't find a better way to automate it. Because when I try to change listener without destroying it I get this error: "Either external ipv4 address or internal ipv4 address or external ipv6 address should be specified for the HTTP route".

## Make commands

SSH

- connect to the host "web2": `make ssh host=web2`

Ansible

- encrypt variables for the "all" group: `make vault-encrypt group=all`
- encrypt variables for the "webservers" group: `make vault-encrypt group=webservers`

Terraform

- plan setup: `make terraform-plan-setup`
- destroy infrastructure: `make terraform-destroy`
- get output: `make -s terraform-show-output`
- get output for the "pg_host" value: `make -s terraform-show-output name=pg_host`

## Demo

[![Hexlet project demo](https://github.com/pochka15/devops-for-programmers-project-77/blob/main/images/HEXLET%20(Demo).png)](https://drive.google.com/file/d/1lXwXmHjtvNAbdcdo1cmZy9FAI2fS2Jl3/view?usp=sharing "Hexlet project demo")
