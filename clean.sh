#! /bin/bash

set -e

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo -e "\033[32mCleaning VM..\033[0m"

export VAGRANT_CWD="${DIR}/vagrant"
vagrant destroy -f
[ -f terraform/terraform.tfstate ] && rm terraform/terraform.tfstate 
[ -f terraform/terraform.tfstate.backup ] && rm terraform/terraform.tfstate.backup
[ -d terraform/.terraform ] && rm -r terraform/.terraform
[ -d vagrant/.vagrant ] && rm -r vagrant/.vagrant

echo -e "\033[32mDone."
