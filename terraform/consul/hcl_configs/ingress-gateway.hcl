Kind = "ingress-gateway"
Name = "ingress-gateway"

Listeners = [
  {
    Port     = 8181
    Protocol = "http"
    Services = [
      {
        Name = "minimal-service"
        Hosts = [
          "minimal-service",
          "minimal-service:8181"
        ]
      },
      {
        Name = "minimal-service-2"
        Hosts = [
          "minimal-service-2",
          "minimal-service-2:8181"
        ]
      }
    ]
  }
]
