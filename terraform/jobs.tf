locals {
  jobs = { for j in fileset(path.module, "jobs/*_job.hcl") : basename(trimsuffix(j, "_job.hcl")) => j }
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
