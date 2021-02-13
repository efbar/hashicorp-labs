# Hashicorp Labs

This repo contains tools for testing and experimenting with Hashicorp software.

But not only that..you can play with `OpenFaas` serverless stuff too! Keep reading.

It will deploy a cluster for `Vault`, `Consul` and `Nomad` where each component will be connected together to form a perfect cluster for testing your application with service mesh

**Table of Contents**
- [Hashicorp Labs](#hashicorp-labs)
  - [Install cluster with Vagrant](#install-cluster-with-vagrant)
  - [Provision and deploy](#provision-and-deploy)
  - [Play with microservices](#play-with-microservices)
  - [OpenFaas in Nomad](#openfaas-in-nomad)
  - [Clean up](#clean-up)


## Install cluster with Vagrant

> WARNING: At the moment the clusters will be loaded in `dev` mode. If the services will fail, you will lose every data since the backends are loaded in memory.

You can choose respective Hashicorp version with these environment variables:

|  ENV | default version |
|---|---|
|  `CONSUL_VERSION`  |  `1.9.3` |
|  `CNI_VERSION`  |  `0.9.0` |
|  `VAULT_VERSION` |  `1.6.2` |
|  `NOMAD_VERSION` | `1.0.3` |
|  `CONTAINERD_VERSION` | `1.4.3-3.1` |
|  `DOCKER_CE_VERSION` | `19.03.13-3` |
|  `ENVOY_VERSION` | `1.16.2` |
|  `FAASD_VERSION` | `0.10.2` |

## Provision and deploy

To provision and deploy the workload simply do:

```bash
./deploy.sh
```

At the end you can reach the services **Vault**, **Consul** and **Nomad** at `localhost`, respectively at `8200`, `8500`, `4646`.

In Consul you should see something like:

![](images/consul.png)

While in Nomad:

![](images/nomad.png)

## Play with microservices

With the provided code you have deployed two microservices `minimal-service` and `minimal-service-2` that can talk to each other.
Both are deployed with Envoy as sidecar, so they are inside the Consul service mesh.

Do some intra-services communication test:

```bash
nomad alloc exec -task minimal-service \
  $(curl -s http://127.0.0.1:4646/v1/job/minimal-service/allocations | \
  jq -r '.[0].ID'| \
  cut -c -8) curl -s 127.0.0.1:8080 | \
  jq
{
  "host": "127.0.0.1:8080",
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

In this cluster we have also deployed `faasd`! So now we can reach OpenFaas gateway and use `OpenFaas` for our serverless testing!

![](images/faasd_task.png)

Just add `127.0.0.1 faasd-gateway` to your `cat /etc/hosts` file and you're done.

Go to `http://faasd-gateway:8181` to enjoy the beautiful OpenFaas homepage.

![](images/openfaas.png)

## Clean up

For clean up just execute `clean.sh`.
