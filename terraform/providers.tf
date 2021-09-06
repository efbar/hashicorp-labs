terraform {
  required_version = ">= 0.13.1, < 1.0.0"
}

provider "consul" {
  address = var.consul_endpoint
  scheme  = "http"
}

provider "nomad" {
  address = var.nomad_endpoint
  region  = "global"
}
