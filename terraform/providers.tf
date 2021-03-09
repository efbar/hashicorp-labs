terraform {
  required_version = ">= 0.13.1"
}

provider "consul" {
  address = var.consul_endpoint
  scheme  = "http"
}

provider "nomad" {
  address = var.nomad_endpoint
  region  = "global"
}
