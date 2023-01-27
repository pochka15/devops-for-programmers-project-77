resource "yandex_mdb_postgresql_cluster" "main-pg-cluster" {
  name        = "main-pg-cluster"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.main-network.id

  config {
    version = 14

    resources {
      resource_preset_id = "b1.nano"
      disk_type_id       = "network-hdd"
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
    subnet_id = yandex_vpc_subnet.main-subnet.id
    name      = "main-postgres-host"
  }
}

resource "yandex_mdb_postgresql_database" "main-pg-db" {
  cluster_id = yandex_mdb_postgresql_cluster.main-pg-cluster.id
  name       = "main-pg-db"
  owner      = yandex_mdb_postgresql_user.hexlet-user.name
  depends_on = [
    yandex_mdb_postgresql_user.hexlet-user
  ]
}

resource "yandex_mdb_postgresql_user" "hexlet-user" {
  cluster_id = yandex_mdb_postgresql_cluster.main-pg-cluster.id
  name       = var.pg_user
  password   = var.pg_password
}
