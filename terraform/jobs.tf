locals {
  jobs = { for j in fileset(path.module, "jobs/*.hcl") : basename(trimsuffix(j, ".hcl")) => j }
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
