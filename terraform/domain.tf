resource "yandex_dns_zone" "hexlet-dns-zone" {
  name             = "hexlet-dns-zone"
  zone             = "${var.release_domain}." # e.x. "example.com."
  public           = true
  private_networks = [yandex_vpc_network.main-network.id]
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
