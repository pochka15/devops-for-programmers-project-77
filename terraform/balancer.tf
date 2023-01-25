resource "yandex_lb_target_group" "main-target-group" {
  name      = "main-target-group"
  region_id = "ru-central1"

  target {
    subnet_id = yandex_vpc_subnet.main-subnet.id
    address   = yandex_compute_instance.web1.network_interface.0.ip_address
  }

  target {
    subnet_id = yandex_vpc_subnet.main-subnet.id
    address   = yandex_compute_instance.web2.network_interface.0.ip_address
  }
}

resource "yandex_lb_network_load_balancer" "main-load-balancer" {
  name = "main-load-balancer"

  listener {
    name = "main-listener"
    port = 443
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.main-target-group.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
    }
  }
}
