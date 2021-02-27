variable "consul_endpoint" {
  type    = string
  default = "http://localhost:8500"
}
variable "nomad_endpoint" {
  type    = string
  default = "http://localhost:4646"
}
variable "enable_gateways" {
  type = bool
  default = true
}
