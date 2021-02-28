job "grafana" {
    datacenters = ["${dc_name}"]

    group "grafana-group" {
        network {
            mode = "bridge"
            port "http" {
              to = 3000
            }
            dns {
              servers = ["10.0.2.15"]
            }
        }

        service {
          name = "grafana"
          port = "http"

          connect {
              sidecar_service {
                proxy {
                  upstreams {
                      destination_name = "prometheus"
                      local_bind_port = 9090
                  }
                }
              }
          }

          check {
            type     = "http"
            protocol = "http"
            port     = "http"
            interval = "30s"
            timeout  = "10s"
            path     = "/api/health"
          }
        }

        task "grafana" {
            driver = "docker"

            config {
                image = "grafana/grafana"
                ports = ["http"]
            }

            resources {
                cpu    = 200
                memory = 250
            }

        }

    }

}
