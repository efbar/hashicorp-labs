resource "consul_config_entry" "terminating_gateway" {
  count = var.enable_gateways ? 1 : 0
  name = "terminating-gateway"
  kind = "terminating-gateway"

  config_json = jsonencode({
    Services = [
      {
        Name = "faasd-gateway"
      },
      {
        Name = "grafana"
      },
      {
        Name = "prometheus"
      }
    ]
  })
}
