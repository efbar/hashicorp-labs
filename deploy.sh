#! /bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo -e "\033[32mPerforming some checks: binaries, versions ..\033[0m"
if ! command -v vagrant &> /dev/null
then
    echo "Vagrant binary could not be found"
    exit 1
fi

if ! command -v terraform &> /dev/null
then
    echo "Terraform binary could not be found"
    exit 1
fi

tfversion=$(terraform version | awk 'NR==1{gsub("v0.",""); print $2}')
tfrequired="13.1"
if (( $(echo "$tfversion < $tfrequired" | bc -l) ));
then
    echo "Terraform version required  >= v0.$tfrequired"
    exit 1
fi

echo -e "\033[32mProvisioning VM..\033[0m"
export VAGRANT_CWD="${DIR}/vagrant"
vagrant validate && \
vagrant up

if [[ $TERRAFORM_LABS == "false" ]];
then
    echo -e "\033[32m 
 Done!

 For services UI:

 => Vault:    http://localhost:8200, pwd: root
 => Consul:   http://localhost:8500
 => Nomad:    http://localhost:4646

\033[0m"
    exit 1
fi

echo -e "\033[32mDeploying workload..\033[0m"
cd ${DIR}/terraform
terraform init && terraform plan && terraform apply -auto-approve && \
echo -e "\033[32m 
 Done!

 Add \"127.0.0.1 faasd-gateway\" to your \"/etc/hosts\" file to reach Openfaasd (same for Prometheus and Grafana).

 For services UI:

=> Vault:               http://localhost:8200, pwd: root
=> Consul:              http://localhost:8500
=> Nomad:               http://localhost:4646
=> Minimal services:    http://localhost:8080
=> OpenFaas:            http://faasd-gateway:8080, user/pwd: admin/password
=> Prometheus:          http://prometheus:8080
=> Grafana:             http://grafana:8080, user/pwd: admin/admin

\033[0m"

