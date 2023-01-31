resource "yandex_alb_load_balancer" "hexlet-balancer" {
  name = "hexlet-balancer"

  network_id = yandex_vpc_network.main-network.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.main-subnet.id
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
  # Note: it works only when yandex_cm_certificate.pochka15-certificate.status == "ISSUED"
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

  #       certificate_ids = [yandex_cm_certificate.pochka15-certificate.id]
  #     }
  #   }
  # }
}

resource "yandex_alb_target_group" "hexlet-target-group" {
  name = "hexlet-target-group"

  target {
    subnet_id  = yandex_vpc_subnet.main-subnet.id
    ip_address = yandex_compute_instance.web1.network_interface.0.ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.main-subnet.id
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
