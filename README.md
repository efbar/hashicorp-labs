# Hashicorp Labs

This repo contains tools for testing and experimenting with Hashicorp software.

But not only that..you can play with `OpenFaas` serverless stuff too! Keep reading.

It will deploy a cluster for `Vault`, `Consul` and `Nomad` where each component will be connected together to form a perfect environment for testing your applications with service mesh.

**Table of Contents**
- [Hashicorp Labs](#hashicorp-labs)
  - [Install cluster with Vagrant](#install-cluster-with-vagrant)
  - [Provision and deploy](#provision-and-deploy)
  - [Play with microservices](#play-with-microservices)
  - [OpenFaas in Nomad](#openfaas-in-nomad)
    - [Monitoring OpenFaas](#monitoring-openfaas)
  - [Clean up](#clean-up)


## Install cluster with Vagrant

> WARNING: At the moment the clusters will be loaded in `dev` mode. If the services will fail, you will lose every data since the backends are loaded in memory.

> Vagrant file is taken partially from here [hashicorp's nomad-guides](https://github.com/hashicorp/nomad-guides/tree/master/operations/provision-nomad/dev/vagrant-local)
It's been revisited and modified (and it will be upgraded in the future).

You can choose respective software versions and VM specs with these environment variables:

|  ENV | description | default value |
|---|---|---|
|  `VAGRANT_CPU_NUM` | `Number of cpu used by VM` | `2` |
|  `VAGRANT_MEM` | `Memory used by VM` | `8192` |
|  `VAULT_VERSION` |`Vault version`| `1.6.3` |
|  `CONSUL_VERSION` |`Consul version`| `1.9.4` |
|  `NOMAD_VERSION` |`NOMAD version`| `1.0.4` |
|  `CNI_VERSION` |`CNI plugin version`| `0.9.0` |
|  `CONTAINERD_VERSION` |`Containerd version`| `1.4.3-3.1` |
|  `DOCKER_CE_VERSION` |`Docker CE version`| `20.10.3-3` |
|  `ENVOY_VERSION` |`Envoy version`| `1.16.2` |
|  `TF_VAR_faasd_version` |`Faasd provider version`| `0.11.2` |
|  `TF_VAR_faas_nats_version` |`NATS version version`| `0.11.2` |
|  `TF_VAR_faas_auth_plugin_version` |`Faas Auth plugin version`| `0.20.5` |
|  `TF_VAR_faas_gateway_version` |`Faas Gateway version`| `0.20.8` |
|  `TF_VAR_faas_queue_worker_version` |`Faas Queue Worker version`| `0.11.2` |

## Provision and deploy

> You need Hashicorp **Terraform** (version >= 0.14.1) and **Vagrant** installed (version >= 2.2.1).

To provision and deploy the workload simply do:

```bash
./deploy.sh
```

At the end, if everything went fine, you can reach the services **Vault**, **Consul** and **Nomad** at `localhost`, respectively at `8200`, `8500`, `4646`.
While Consul Ingress Gateway is listening at port `8080`, where you can find some preinstalled services.

In Consul you should see something like:

![](images/consul.png)

While in Nomad:

![](images/nomad.png)

## Play with microservices

With the provided code you could deployed two microservices `minimal-service` and `minimal-service-2` that can talk to each other.

If you go inside `terraform` folder and do:

```bash
terraform apply -var deploy_example_jobs=true -auto-approve
```

you'll find both in the cluster.

Both are deployed by Nomad with Envoy as sidecar, so they are inside the Consul service mesh.

Do some intra-services communication test:

```bash
nomad alloc exec -task minimal-service \
  $(curl -s http://127.0.0.1:4646/v1/job/minimal-service/allocations | \
  jq -r '.[0].ID'| \
  cut -c -8) curl -s 127.0.0.1:8080 | \
  jq
{
  "host": "127.0.0.1:9090",
  "statuscode": 200,
  "headers": {
    "Accept": "*/*",
    "Content-Length": "0",
    "Duration": "0.030891",
    "Request-time": "2021-02-13 19:08:03.673759094 +0000 UTC",
    "Response-time": "2021-02-13 19:08:03.673789985 +0000 UTC",
    "User-Agent": "curl/7.69.1",
    "X-Envoy-Expected-Rq-Timeout-Ms": "15000",
    "X-Forwarded-Proto": "http",
    "X-Request-Id": "cd6dcc66-f73c-4d16-8783-e4c7690bb929"
  },
  "protocol": "HTTP/1.1",
  "requestURI": "/",
  "servedBy": "6194ce0dea8d",
  "method": "GET"
}
```

with this command we go inside `minimal-service` container and execute a `GET` request to localhost at port 8080. At that port Envoy proxy is listening to requests, in this case it will proxy the request to `minimal-service-2`. This is just an example.

## OpenFaas in Nomad

In this cluster, by default, we have also deployed `faasd`! So now we can reach OpenFaas gateway and use `OpenFaas` for our serverless testing!

![](images/faasd_task.png)

Just add `127.0.0.1 faasd-gateway` to your `/etc/hosts` file and you're done.

Go to `http://faasd-gateway:8080` to enjoy the beautiful OpenFaas homepage.

![](images/openfaas.png)

### Monitoring OpenFaas

Add `127.0.0.1 grafana` to your `/etc/hosts` file and go to `http://grafana:8080`.
Both dashboard are taken from Grafana dashboard repos with few modifications:
- [Nomad jobs](https://grafana.com/grafana/dashboards/12787)
  ![](images/grafana-nomad.png)
- [Faasd](https://grafana.com/grafana/dashboards/11202)
  ![](images/grafana-faasd.png)


## Clean up

For cleaning up just execute `clean.sh`.
