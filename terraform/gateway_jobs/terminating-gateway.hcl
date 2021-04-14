job "terminating-gateway" {

  datacenters = ["${dc_name}"]

  group "terminating-group" {

    network {
      mode = "bridge"
      port "inbound" {
        static = 8088
        to     = 8080
      }
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
