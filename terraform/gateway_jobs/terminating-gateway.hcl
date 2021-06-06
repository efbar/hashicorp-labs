job "terminating-gateway" {

  datacenters = ["${dc_name}"]

  group "terminating-group" {

    network {
      mode = "host"
      port "inbound" {}
    }

    service {
      name = "terminating-service"
      port = "inbound"

      connect {
        gateway {
          proxy {}
          terminating {
            service {
              name = "faasd-gateway"
            }
            service {
              name = "prometheus"
            }
            service {
              name = "grafana"
            }
          }
        }
      }
    }
  }
}
