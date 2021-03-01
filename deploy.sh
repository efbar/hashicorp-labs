#! /bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo -e "\033[32mProvisioning VM..\033[0m"
export VAGRANT_CWD="${DIR}/vagrant"
vagrant validate && \
vagrant up

echo -e "\033[32mDeploying workload..\033[0m"
cd ${DIR}/terraform
terraform init && terraform plan && terraform apply -auto-approve && \
echo -e "\033[32m 
 Done!

 Add `127.0.0.1 faasd-gateway` to your `/etc/hosts` file.

 For services UI:

=> Vault:               http://localhost:8200
=> Consul:              http://localhost:8500
=> Nomad:               http://localhost:4646
=> Minimal services:    http://localhost:8080
=> OpenFaas:            http://faasd-gateway:8080, user/pwd: admin/password
=> Prometheus:          http://prometheus:8080
=> Grafana:             http://grafana:8080, user/pwd: admin/admin

\033[0m"

