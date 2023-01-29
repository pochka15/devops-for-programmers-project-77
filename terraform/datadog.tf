resource "datadog_dashboard" "healthcheck_dashboard" {
  title        = "Webserver healthcheck"
  layout_type  = "ordered"
  is_read_only = true

  widget {
    # todo: Add a healthcheck widget that makes a request to the http://localhost/
  }
}
