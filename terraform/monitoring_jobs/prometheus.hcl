job "prometheus" {
    datacenters = ["${dc_name}"]

    group "prometheus-group" {
        network {
            mode = "bridge"

            port "http" {
              to = 9090
            }

            dns {
              servers = ["10.0.2.15"]
            }
        }

        service {
          name = "prometheus"
          port = "http"

          connect {
              sidecar_service {
              }
          }

          check {
            type     = "http"
            protocol = "http"
            port     = "http"
            interval = "10s"
            timeout  = "2s"
            path     = "/-/healthy"
          }
        }

        ephemeral_disk {
          size = 300
        }

        task "prometheus" {
            driver = "docker"

            template {
              data = <<EOH
              global:
                scrape_interval: 10s

              scrape_configs:
                - job_name: 'prometheus_master'
                  scrape_interval: 15s
                  static_configs:
                    - targets: ['localhost:9090']

                - job_name: "gateway"
                  scheme: http
                  tls_config:
                    insecure_skip_verify: true
                  consul_sd_configs:
                    - server: 'http://10.0.2.15:8500'
                      services: ['faasd-mon']

                - job_name: 'nomad'
                  scheme: http
                  tls_config:
                    insecure_skip_verify: true
                  consul_sd_configs:
                    - server: 'http://10.0.2.15:8500'
                      services: ['nomad']

                  relabel_configs:
                    - source_labels: ['__meta_consul_tags']
                      regex: '(.*)http(.*)'
                      action: keep

                  scrape_interval: 10s
                  metrics_path: /v1/metrics
                  params:
                    format: ['prometheus']
                - job_name: 'nomad-client'
                  scheme: http
                  tls_config:
                    insecure_skip_verify: true
                  consul_sd_configs:
                    - server: 'http://10.0.2.15:8500'
                      services: ['nomad-client']

                  relabel_configs:
                    - source_labels: ['__meta_consul_tags']
                      regex: '(.*)http(.*)'
                      action: keep

                  scrape_interval: 10s
                  metrics_path: /v1/metrics
                  params:
                    format: ['prometheus']
              EOH
              destination = "local/prometheus.yml"
            }

            config {
                image = "prom/prometheus"
                ports = ["http"]

                volumes = [
                  "local/prometheus.yml:/etc/prometheus/prometheus.yml",
                ]
            }

            resources {
                cpu    = 200
                memory = 250
            }

        }

    }

}
