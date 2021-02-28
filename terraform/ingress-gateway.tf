resource "consul_config_entry" "ingress_gateway" {
  count = var.enable_gateways ? 1 : 0
  depends_on = [
    consul_config_entry.proxy_defaults
  ]
  name = "ingress-gateway"
  kind = "ingress-gateway"

  config_json = jsonencode({
    Listeners = [{
      Port     = 9090
      Protocol = "http"
      Services = [
        {
          Name = "minimal-service"
          Hosts = [
            "minimal-service",
            "minimal-service:9090",
          ]
        },
        {
          Name = "minimal-service-2"
          Hosts = [
            "minimal-service-2",
            "minimal-service-2:9090",
          ]
        },
        {
          Name = "prometheus"
          Hosts = [
            "prometheus",
            "prometheus:9090",
          ]
        },
        {
          Name = "grafana"
          Hosts = [
            "grafana",
            "grafana:9090",
          ]
        }
      ]
    }]
  })
}
