resource "consul_config_entry" "ingress_gateway" {
  depends_on = [
    consul_config_entry.proxy_defaults
  ]
  name = "ingress-gateway"
  kind = "ingress-gateway"

  config_json = jsonencode({
    Listeners = [{
      Port     = 8181
      Protocol = "http"
      Services = [
        {
          Name = "minimal-service"
          Hosts = [
            "minimal-service",
            "minimal-service:8080",
          ]
        },
        {
          Name = "minimal-service-2"
          Hosts = [
            "minimal-service-2",
            "minimal-service-2:8080",
          ]
        },
        {
          Name = "faasd-gateway"
          Hosts = [
            "faasd-gateway",
            "faasd-gateway:8080",
          ]
        }
      ]
    }]
  })
}
