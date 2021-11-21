variable "consul_endpoint" {
  type    = string
  default = "http://localhost:8500"
}
variable "nomad_endpoint" {
  type    = string
  default = "http://localhost:4646"
}
variable "deploy_example_jobs" {
  type    = bool
  default = false
}
variable "faasd_version" {
  type    = string
  default = "0.14.3"
}
variable "faasd_arm" {
  type    = bool
  default = true
}
variable "faas_nats_version" {
  type    = string
  default = "0.22.0"
}
variable "faas_auth_plugin_version" {
  type    = string
  default = "0.21.0"
}
variable "faas_gateway_version" {
  type    = string
  default = "0.21.0"
}
variable "faas_queue_worker_version" {
  type    = string
  default = "0.12.2"
}
