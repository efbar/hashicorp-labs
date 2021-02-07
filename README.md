# Hashicorp Labs

This repo contains tools for testing and experimenting with Hashicorp software.

It will deploy a cluster for `Vault`, `Consul` and `Nomad` where each component will be connected together.

**Table of Contents**
- [Hashicorp Labs](#hashicorp-labs)
  - [Install cluster with Vagrant](#install-cluster-with-vagrant)
  - [Deploy in Nomad](#deploy-in-nomad)


## Install cluster with Vagrant

_Vagrant file is taken partially from here [https://github.com/hashicorp/nomad-guides/tree/master/operations/provision-nomad/dev/vagrant-local](https://github.com/hashicorp/nomad-guides/tree/master/operations/provision-nomad/dev/vagrant-local)
It's been revisioned and modified._

| WARNING: At the moment the clusters will be loaded in `dev` mode. If the services will fail, you will lose every data since the backends are loaded in memory.|
| --- |

You can choose respective Hashicorp version with these environment variables:

|  ENV | default version |
|---|---|
|  `CONSUL_VERSION`  |  `1.9.3` |
|  `CNI_VERSION`  |  `0.9.0` |
|  `VAULT_VERSION` |  `1.6.2` |
|  `NOMAD_VERSION` | `1.0.3` |
|  `CONTAINERD_VERSION` | `1.4.3-3.1` |
|  `DOCKER_CE_VERSION` | `19.03.13-3` |
|  `ENVOY_VERSION` | `1.14.5` |

Inside `vagrant` folder:

```bash
vagrant up
```

If you want to expose the services UI at `http://localhost:<service_port>`.

## Deploy in Nomad

You can try to deploy two services that talk to each other. Go inside `nomad` folder:

```bash
nomad run minimal-service.hcl
nomad run minimal-service-2.hcl
```

Do some intra-services communication test:

```bash
nomad alloc exec -task minimal-service \
  $(curl -s http://127.0.0.1:4646/v1/job/minimal-service/allocations | \
  jq -r '.[0].ID'| \
  cut -c -8) curl -s 127.0.0.1:8080 | \
  jq
```

