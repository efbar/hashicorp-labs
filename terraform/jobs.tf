locals {
  jobs = { for j in fileset(path.module, "jobs/*.hcl") : basename(trimsuffix(j, ".hcl")) => j }
  gateway_jobs = { for j in fileset(path.module, "gateway_jobs/*.hcl") : basename(trimsuffix(j, ".hcl")) => j }
  example_jobs = { for j in fileset(path.module, "example_jobs/*.hcl") : basename(trimsuffix(j, ".hcl")) => j }
}

resource "nomad_job" "jobs" {
  for_each = local.jobs
  jobspec = templatefile(
    each.value,
    {
      dc_name = "dc1",
      faasd_version = var.faasd_version,
      faas_nats_version = var.faas_nats_version,
      faas_auth_plugin_version = var.faas_auth_plugin_version,
      faas_gateway_version = var.faas_gateway_version,
      faas_queue_worker_version = var.faas_queue_worker_version,
    }
  )
}

resource "nomad_job" "gateway_jobs" {
  for_each = local.gateway_jobs
  jobspec = templatefile(
    each.value,
    {
      dc_name = "dc1",
    }
  )
}

resource "nomad_job" "example_jobs" {
  for_each = var.deploy_example_jobs ? local.example_jobs : {}
  jobspec = templatefile(
    each.value,
    {
      dc_name = "dc1",
    }
  )
}
