# Hashicorp Labs

This repo contains tools for testing and experimenting with Hashicorp software.

It will deploy a cluster for `Vault`, `Consul` and `Nomad` where each component will be connected together.


> Vagrant file is taken partially from here [https://github.com/hashicorp/nomad-guides/tree/master/operations/provision-nomad/dev/vagrant-local](https://github.com/hashicorp/nomad-guides/tree/master/operations/provision-nomad/dev/vagrant-local)
It's been revisioned and modified.


##### Vagrant deploy

| WARNING: At the moment the clusters will be loaded in `dev` mode. If the services will fail, you will lose every data since the backends are loaded in memory.|
| --- |

You can choose rispective Hashicorp version with these environment variables:

|  ENV | default version |
|---|---|
| `CONSUL_VERSION`  |  `1.8.6` |
| `CNI_VERSION`  |  `0.8.6` |
|  `VAULT_VERSION` |  `1.6.0` |
|  `CNI_VERSION` | `0.8.6` |
|  `VAULT_VERSION` | `1.6.0` |
|  `NOMAD_VERSION` | `0.12.8` |
|  `CONTAINERD_VERSION` | `1.3.7-3.1` |
|  `DOCKER_CE_VERSION` | `19.03.13-3` |
|  `ENVOY_VERSION` | `1.14.5` |

Inside `vagrant` folder:

```bash
vagrant up
```

If you want to expose the services UI, you can do something like:

```bash
vagrant ssh -- -L 8200:localhost:8200 -L 8500:localhost:8500 -L 4646:localhost:4646
```

Now you can reach those service at `http://localhost:<service_port>`
