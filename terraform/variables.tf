variable "yandex_token" {}
variable "yandex_cloud_id" {}
variable "yandex_folder_id" {}

variable "yandex_user" {
  default = "ubuntu"
  type    = string
}

variable "public_ssh_key_path" {
  default = "~/.ssh/id_rsa.pub"
  type    = string
}

variable "pg_user" {
  default = "postgres"
  type    = string
}

variable "pg_password" {
  default = "password"
  type    = string
}

