#! /bin/bash

set -e

[[ -f faasd ]] || wget -q https://github.com/openfaas/faasd/releases/download/${FAASD_VERSION}/faasd && \
sudo mv faasd /usr/local/bin/faasd && chmod +x /usr/local/bin/faasd
