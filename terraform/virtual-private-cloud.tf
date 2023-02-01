resource "yandex_vpc_network" "hexlet-network" {
  name = "hexlet-network"
}

resource "yandex_vpc_subnet" "hexlet-subnet-a" {
  name           = "hexlet-subnet-a"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.hexlet-network.id
  v4_cidr_blocks = ["10.5.0.0/24"]
}
