job "consul-ingress" {
  datacenters = ["${dc_name}"]

  group "ingress-group" {
    network {
      port "http" {}
      mode = "host"
    }
    task "ingress" {
      driver = "exec"
      user   = "consul"
      config {
        command = "/usr/local/bin/consul"
        args = [
          "connect", "envoy",
          "-envoy-binary", "/usr/bin/envoy",
          "-envoy-version", "1.16.2",
          "-gateway=ingress",
          "-register",
          "-service", "ingress-gateway",
          "-address", "$${NOMAD_IP_http}:$${NOMAD_PORT_http}",
          "-http-addr", "http://127.0.0.1:8500",
          "-grpc-addr", "http://127.0.0.1:8502"
        ]
      }
      resources {
         cpu    = 500
         memory = 250
      }
    }
  }
}
