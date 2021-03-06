#!/bin/bash
set -x

echo "Docker install and envoy for docker install"

# install docker and envoy for docker
[ -f containerd.io-${CONTAINERD_VERSION}.el7.x86_64.rpm ] || wget -q https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-${CONTAINERD_VERSION}.el7.x86_64.rpm && \
[ -f docker-ce-${DOCKER_CE_VERSION}.el7.x86_64.rpm ] || wget -q https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-${DOCKER_CE_VERSION}.el7.x86_64.rpm && \
[ -f docker-ce-cli-${DOCKER_CE_VERSION}.el7.x86_64.rpm ] || wget -q https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-cli-${DOCKER_CE_VERSION}.el7.x86_64.rpm && \
[ -f docker-ce-rootless-extras-${DOCKER_CE_VERSION}.el7.x86_64.rpm ] || wget -q https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-rootless-extras-${DOCKER_CE_VERSION}.el7.x86_64.rpm && \
sudo yum install -y containerd.io-${CONTAINERD_VERSION}.el7.x86_64.rpm docker-ce-${DOCKER_CE_VERSION}.el7.x86_64.rpm docker-ce-cli-${DOCKER_CE_VERSION}.el7.x86_64.rpm  docker-ce-rootless-extras-${DOCKER_CE_VERSION}.el7.x86_64.rpm && \
sudo usermod -G docker -a nomad && \
sudo systemctl start docker && \
sudo docker pull envoyproxy/envoy:${ENVOY_VERSION} && \
sudo systemctl stop docker && sudo systemctl enable docker && \
sudo mv /tmp/docker-login.service /etc/systemd/system/ && \
sudo mv /tmp/docker-login.sh /usr/local/bin/docker-login.sh && \
sudo chmod +x /usr/local/bin/docker-login.sh && \
sudo systemctl enable docker-login.service

sudo sh -c "echo \"DOCKER_OPTS='--dns 127.0.0.1 --dns 8.8.8.8 --dns-search service.consul'\" >> /etc/default/docker"

sudo systemctl enable docker
sudo systemctl start docker

echo "Complete"
