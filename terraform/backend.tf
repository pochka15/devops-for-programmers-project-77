terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "~> 0.84.0"
    }
  }
}

resource "yandex_alb_load_balancer" "hexlet-balancer" {
  name = "hexlet-balancer"

  network_id = yandex_vpc_network.hexlet-network.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.hexlet-subnet-a.id
    }
  }

  # HTTP listener
  listener {
    name = "http-listener"

    endpoint {
      address {
        external_ipv4_address {
        }
      }

      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.hexlet-router.id
      }
    }
  }

  # HTTPS listener
  # Note: it works only when yandex_cm_certificate.main-domain-certficate.status == "ISSUED"
  # listener {
  #   name = "https-listener"

  #   endpoint {
  #     address {
  #       external_ipv4_address {
  #       }
  #     }

  #     ports = [443]
  #   }

  #   tls {
  #     default_handler {
  #       http_handler {
  #         http_router_id = yandex_alb_http_router.hexlet-router.id
  #       }

  #       certificate_ids = [yandex_cm_certificate.main-domain-certficate.id]
  #     }
  #   }
  # }
}

resource "yandex_alb_target_group" "hexlet-target-group" {
  name = "hexlet-target-group"

  target {
    subnet_id  = yandex_vpc_subnet.hexlet-subnet-a.id
    ip_address = yandex_compute_instance.web1.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.hexlet-subnet-a.id
    ip_address = yandex_compute_instance.web2.network_interface.0.ip_address
  }
}

resource "yandex_alb_backend_group" "hexlet-backend-group" {
  name = "hexlet-backend-group"

  http_backend {
    name             = "hexlet-http-backend"
    weight           = 1
    port             = 80
    target_group_ids = ["${yandex_alb_target_group.hexlet-target-group.id}"]

    load_balancing_config {
      panic_threshold = 50
    }

    healthcheck {
      timeout  = "1s"
      interval = "1s"

      http_healthcheck {
        path = "/"
      }
    }
  }
}

resource "yandex_alb_http_router" "hexlet-router" {
  name = "hexlet-router"
}

resource "yandex_alb_virtual_host" "hexlet-virtual-host" {
  name           = "hexlet-virtual-host"
  http_router_id = yandex_alb_http_router.hexlet-router.id

  route {
    name = "main-route"

    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.hexlet-backend-group.id
        timeout          = "15s"
      }
    }
  }
}
resource "yandex_mdb_postgresql_cluster" "hexlet-cluster" {
  name        = "hexlet-cluster"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.hexlet-network.id

  config {
    version = 13

    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 10
    }
  }

  maintenance_window {
    type = "WEEKLY"
    day  = "SAT"
    hour = 12
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.hexlet-subnet-a.id
    name      = "main-postgres-host"
  }
}

resource "yandex_mdb_postgresql_database" "hexlet-db" {
  cluster_id = yandex_mdb_postgresql_cluster.hexlet-cluster.id
  name       = var.pg_database
  owner      = yandex_mdb_postgresql_user.hexlet-user.name
  depends_on = [
    yandex_mdb_postgresql_user.hexlet-user
  ]
}

resource "yandex_mdb_postgresql_user" "hexlet-user" {
  cluster_id = yandex_mdb_postgresql_cluster.hexlet-cluster.id
  name       = var.pg_user
  password   = var.pg_password
}
resource "yandex_dns_zone" "hexlet-dns-zone" {
  name             = "hexlet-dns-zone"
  zone             = "${var.release_domain}." # e.x. "example.com."
  public           = true
  private_networks = [yandex_vpc_network.hexlet-network.id]
}

resource "yandex_dns_recordset" "balancer-record" {
  zone_id = yandex_dns_zone.hexlet-dns-zone.id
  name    = "${var.release_domain}." # e.x. "example.com."
  type    = "A"
  ttl     = 600
  data    = [yandex_alb_load_balancer.hexlet-balancer.listener.0.endpoint.0.address.0.external_ipv4_address.0.address]
}

resource "yandex_dns_recordset" "certificate-challenge-record" {
  zone_id = yandex_dns_zone.hexlet-dns-zone.id
  name    = yandex_cm_certificate.main-domain-certficate.challenges[0].dns_name
  type    = yandex_cm_certificate.main-domain-certficate.challenges[0].dns_type
  data    = [yandex_cm_certificate.main-domain-certficate.challenges[0].dns_value]
  ttl     = 600
}

resource "yandex_cm_certificate" "main-domain-certficate" {
  name    = "main-domain-certficate"
  domains = [var.release_domain]

  managed {
    challenge_type = "DNS_CNAME"
  }
}
output "webservers" {
  value = [
    yandex_compute_instance.web1,
    yandex_compute_instance.web2
  ]
}

output "pg_host" {
  value = one(yandex_mdb_postgresql_cluster.hexlet-cluster.host).fqdn
}
provider "yandex" {
  token     = var.yandex_token
  cloud_id  = var.yandex_cloud_id
  folder_id = var.yandex_folder_id
  zone      = "ru-central1-a"
}
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

variable "pg_database" {
  default = "database"
  type    = string
}

variable "release_domain" {
  type = string
}
resource "yandex_compute_instance" "web1" {
  name        = "web1"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 8
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8ueg1g3ifoelgdaqhb" # Ubuntu 22.04 LTS
      size     = 15
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.hexlet-subnet-a.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.yandex_user}:${file(var.public_ssh_key_path)}"
  }
}

resource "yandex_compute_instance" "web2" {
  name        = "web2"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 8
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8ueg1g3ifoelgdaqhb" # Ubuntu 22.04 LTS
      size     = 15
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.hexlet-subnet-a.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.yandex_user}:${file(var.public_ssh_key_path)}"
  }
}
resource "yandex_vpc_network" "hexlet-network" {
  name = "hexlet-network"
}

resource "yandex_vpc_subnet" "hexlet-subnet-a" {
  name           = "hexlet-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.hexlet-network.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}
