output "webservers" {
  value = [
    yandex_compute_instance.web1,
    yandex_compute_instance.web2
  ]
}

output "pg_host" {
  value = one(yandex_mdb_postgresql_cluster.hexlet-cluster.host).fqdn
}
