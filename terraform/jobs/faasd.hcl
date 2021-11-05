job "faasd_bundle" {
  datacenters = ["${dc_name}"]
  type        = "service"

  group "faasd" {

    restart {
      attempts = 100
      delay    = "5s"
      interval = "10m"
      mode     = "delay"
    }

    network {
      port "faasd_provider_tcp" {
        static = 8081
        to     = 8081
      }
      port "auth_http" {}
      port "nats_tcp_client" {
        to = 4222
      }
      port "nats_http_mon" {
        to = 8222
      }
      port "gateway_http" {
        to = 8080
      }
      port "gateway_mon" {
        to = 8082
      }
      dns {
        servers = ["192.168.50.153"]
      }
    }

    service {
      name = "faasd-basic-auth"
      tags = ["serverless"]
      port = "auth_http"

      check {
        type     = "tcp"
        port     = "auth_http"
        interval = "5s"
        timeout  = "2s"
      }
    }

    service {
      name = "faasd-nats"
      tags = ["serverless"]
      port = "nats_tcp_client"

      check {
        type     = "tcp"
        port     = "nats_tcp_client"
        interval = "5s"
        timeout  = "2s"
      }
    }

    service {
      name = "faasd-nats-monitoring"
      tags = ["serverless"]
      port = "nats_http_mon"

      check {
        type     = "http"
        path     = "/connz"
        port     = "nats_http_mon"
        interval = "30s"
        timeout  = "2s"
      }
    }

    service {
      name = "faasd-gateway"
      tags = ["serverless"]
      port = "gateway_http"

      check {
        type     = "http"
        path     = "/healthz"
        port     = "gateway_http"
        interval = "5s"
        timeout  = "2s"
      }
    }


    service {
      name = "faasd-provider"
      tags = ["serverless"]
      port = "faasd_provider_tcp"
      check {
        type     = "tcp"
        port     = "faasd_provider_tcp"
        interval = "5s"
        timeout  = "2s"
      }
    }

    task "download-faasd" {
      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      driver = "raw_exec"
      config {
        command = "sh"
        args    = ["-c", "wget -q https://github.com/openfaas/faasd/releases/download/${faasd_version}/faasd && mkdir -p /var/lib/faasd && touch /var/lib/faasd/hosts /var/lib/faasd/resolv.conf && mv faasd /usr/local/bin/faasd && chmod +x /usr/local/bin/faasd"]
      }
    }

    task "faasd_provider" {
      driver = "raw_exec"
      config {
        command = "/usr/local/bin/faasd"
        args    = ["provider"]
      }
      resources {
        cpu    = 100
        memory = 500
      }
      env {
        service_timeout = "${timeout}"
      }
    }

    task "nats" {
      driver = "docker"
      config {
        image      = "docker.io/library/nats-streaming:${faas_nats_version}"
        ports      = ["nats_tcp_client", "nats_http_mon"]
        entrypoint = ["/nats-streaming-server"]
        args = [
          "-p",
          "$${NOMAD_PORT_nats_tcp_client}",
          "-m",
          "$${NOMAD_PORT_nats_http_mon}",
          "--store=memory",
          "--cluster_id=faas-cluster",
          "-DV"
        ]
      }
      env {
        read_timeout  = "${timeout}"
        write_timeout = "${timeout}"
      }
      resources {
        cpu    = 50
        memory = 50
      }
    }

    task "basic-auth-plugin" {
      driver = "docker"

      config {
        image = "ghcr.io/openfaas/basic-auth:${faas_auth_plugin_version}"
        ports = ["auth_http"]

      }

      template {
        data        = "password"
        destination = "secrets/basic-auth-password"
      }

      template {
        data        = "admin"
        destination = "secrets/basic-auth-user"
      }

      env {
        port              = "$${NOMAD_PORT_auth_http}"
        secret_mount_path = "/secrets/"
        user_filename     = "basic-auth-user"
        pass_filename     = "basic-auth-password"
      }

      resources {
        cpu    = 20
        memory = 30
      }
    }

    task "gateway" {
      driver = "docker"
      config {
        image = "ghcr.io/openfaas/gateway:${faas_gateway_version}"
        ports = ["gateway_http", "gateway_mon"]
      }
      template {
        data        = "password"
        destination = "secrets/basic-auth-password"
      }
      template {
        data        = "admin"
        destination = "secrets/basic-auth-user"
      }
      env {
        basic_auth             = "true"
        functions_provider_url = "http://faasd-provider.service.consul:$${NOMAD_HOST_PORT_faasd_provider_tcp}/"
        direct_functions       = "false"
        read_timeout           = "${timeout}"
        write_timeout          = "${timeout}"
        upstream_timeout       = "${timeout}"
        faas_prometheus_host   = "$${NOMAD_HOST_IP_gateway_mon}"
        faas_nats_address      = "faasd-nats.service.consul"
        faas_nats_port         = "$${NOMAD_HOST_PORT_nats_tcp_client}"
        auth_proxy_url         = "http://faasd-basic-auth.service.consul:$${NOMAD_HOST_PORT_auth_http}/validate"
        auth_proxy_pass_body   = "false"
        secret_mount_path      = "/secrets"
        scale_from_zero        = "true"
        function_namespace     = "openfaas-fn"
      }
      resources {
        cpu    = 50
        memory = 50
      }
    }

    task "queue-worker" {
      driver = "docker"
      config {
        image = "ghcr.io/openfaas/queue-worker:${faas_queue_worker_version}"
      }
      template {
        data        = "password"
        destination = "secrets/basic-auth-password"
      }

      template {
        data        = "admin"
        destination = "secrets/basic-auth-user"
      }
      env {
        faas_nats_address    = "faasd-nats.service.consul"
        faas_nats_port       = "$${NOMAD_HOST_PORT_nats_tcp_client}"
        gateway_invoke       = "true"
        faas_gateway_address = "faads-gateway.service.consul:$${NOMAD_HOST_PORT_gateway_http}"
        ack_wait             = "${timeout}"
        max_inflight         = "1"
        write_debug          = "true"
        basic_auth           = "true"
        secret_mount_path    = "/secrets"
      }
      resources {
        cpu    = 50
        memory = 50
      }
    }
  }
}
