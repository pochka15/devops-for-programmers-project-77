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
