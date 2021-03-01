variable "consul_endpoint" {
  type    = string
  default = "http://localhost:8500"
}
variable "nomad_endpoint" {
  type    = string
  default = "http://localhost:4646"
}
variable "deploy_example_jobs" {
  type = bool
  default = false
}
