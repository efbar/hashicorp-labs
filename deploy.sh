#! /bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo -e "\033[32mProvisioning VM..\033[0m"
export VAGRANT_CWD="${DIR}/vagrant"
vagrant validate && \
vagrant up

echo -e "\033[32mDeploying workload..\033[0m"
cd ${DIR}/terraform
terraform init && terraform plan && terraform apply -auto-approve
