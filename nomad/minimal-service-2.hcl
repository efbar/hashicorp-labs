job "minimal-service-2" {
    datacenters = ["dc1"]

    group "minimal-service-group" {
        network {
            mode = "bridge"
            port "http" {}
        }

        service {
          name = "minimal-service-2"
          port = "http"

          connect {
              sidecar_service {}
          }

          check {
            type     = "http"
            protocol = "http"
            port     = "http"
            interval = "25s"
            timeout  = "35s"
            path     = "/health"
          }
        }

        task "minimal-service" {
            driver = "docker"

            config {
                image = "efbar/minimal-service:1.0.1"
                ports = ["http"]
            }

            env {
              SERVICE_PORT="${NOMAD_PORT_http}"
            }

            resources {
                cpu    = 200
                memory = 250
            }

        }

    }

}
