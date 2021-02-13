job "consul-terminating" {
  datacenters = ["${dc_name}"]

  group "terminating-group" {
    network {
      port "http" {}
      mode = "host"
    }
    task "terminating" {
      driver = "exec"
      user   = "consul"
      config {
        command = "/usr/local/bin/consul"
        args = [
          "connect", "envoy",
          "-envoy-binary", "/usr/bin/envoy",
          "-envoy-version", "1.16.2",
          "-gateway=terminating",
          "-register",
          "-service", "terminating-gateway",
          "-admin-bind", "127.0.0.1:19001",
          "-address", "$${NOMAD_ADDR_http}",
          "-http-addr", "http://127.0.0.1:8500",
        ]
      }
      resources {
         cpu    = 500
         memory = 250
      }
    }
  }
}
