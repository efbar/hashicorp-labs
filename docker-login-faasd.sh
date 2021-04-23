#! /bin/bash

set -e

DOCKER_USER=$1
DOCKER_PASS=$2

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
echo -e "\033[32mDocker login for Faasd..\033[0m"
export VAGRANT_CWD="${DIR}/vagrant"
vagrant ssh -c "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin && mkdir -p /var/lib/faasd/.docker && cp .docker/config.json /var/lib/faasd/.docker/config.json"
echo -e "\033[32m 
Done.
\033[0m"
