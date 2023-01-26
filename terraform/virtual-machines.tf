resource "yandex_compute_instance" "web1" {
  name        = "web1"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores         = 2
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8ueg1g3ifoelgdaqhb" # Ubuntu 22.04 LTS
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.main-subnet.id
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
    memory        = 4
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8ueg1g3ifoelgdaqhb" # Ubuntu 22.04 LTS
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.main-subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.yandex_user}:${file(var.public_ssh_key_path)}"
  }
}
