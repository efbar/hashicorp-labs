job "ingress-gateway" {

  datacenters = ["${dc_name}"]

  group "ingress-group" {

    network {
      mode = "bridge"
      port "inbound" {
        static = 8080
        to     = 8080
      }
    }

    service {
      name = "ingress-service"
      port = "inbound"

      connect {
        gateway {
          proxy {}
          ingress {
            listener {
              port     = 8080
              protocol = "http"
              service {
                name = "minimal-service"
                hosts = ["minimal-service","minimal-service:8080" ]
              }
              service {
                name = "minimal-service-2"
                hosts = ["minimal-service-2","minimal-service-2:8080" ]
              }
              service {
                name = "faasd-gateway"
                hosts = ["faasd-gateway","faasd-gateway:8080" ]
              }
              service {
                name = "prometheus"
                hosts = ["prometheus","prometheus:8080" ]
              }
              service {
                name = "grafana"
                hosts = ["grafana","grafana:8080" ]
              }
            }
          }
        }
      }
    }
  }
}
