resource "yandex_vpc_network" "main-network" {}

resource "yandex_vpc_subnet" "main-subnet" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main-network.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}
