resource "consul_config_entry" "minimal-service" {
  name = "minimal-service"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol    = "http"
  })
}

resource "consul_config_entry" "minimal-service-2" {
  name = "minimal-service-2"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol    = "http"
  })
}

resource "consul_config_entry" "faasd-gateway" {
  name = "faasd-gateway"
  kind = "service-defaults"

  config_json = jsonencode({
    Protocol    = "http"
  })
}
