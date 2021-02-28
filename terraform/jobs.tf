locals {
  jobs = { for j in fileset(path.module, "jobs/*.hcl") : basename(trimsuffix(j, ".hcl")) => j }
  gateway_jobs = { for j in fileset(path.module, "gateway_jobs/*.hcl") : basename(trimsuffix(j, ".hcl")) => j }
  monitoring_jobs = { for j in fileset(path.module, "monitoring_jobs/*.hcl") : basename(trimsuffix(j, ".hcl")) => j }
}

resource "nomad_job" "jobs" {
  for_each = local.jobs
  jobspec = templatefile(
    each.value,
    {
      dc_name = "dc1",
    }
  )
}

resource "nomad_job" "gateway_jobs" {
  for_each = var.enable_gateways ? local.gateway_jobs : {}
  jobspec = templatefile(
    each.value,
    {
      dc_name = "dc1",
    }
  )
}

resource "nomad_job" "monitoring_jobs" {
  for_each = local.monitoring_jobs
  jobspec = templatefile(
    each.value,
    {
      dc_name = "dc1",
    }
  )
}
