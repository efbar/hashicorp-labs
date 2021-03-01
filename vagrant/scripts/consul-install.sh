#!/bin/bash
set -x

echo "Consul Pre-install"

GROUP="${GROUP:-}"
USER="${USER:-}"
COMMENT="${COMMENT:-}"
HOME="${HOME:-}"

# RHEL user setup
sudo /usr/sbin/groupadd --force --system ${GROUP}

if ! getent passwd ${USER} >/dev/null ; then
  sudo /usr/sbin/adduser \
    --system \
    --gid ${GROUP} \
    --home ${HOME} \
    --no-create-home \
    --comment "${COMMENT}" \
    --shell /bin/false \
    ${USER}  >/dev/null
fi

echo "Setting up user ${USER} for RHEL/CentOS"
echo "${USER} user not created due to OS detection failure"

# Create & set permissions on HOME directory
sudo mkdir -pm 0755 ${HOME}
sudo chown -R ${USER}:${GROUP} ${HOME}
sudo chmod -R 0755 ${HOME}

echo "==============="
echo "Consul Install"

CONSUL_VERSION=${VERSION}
CONSUL_ZIP=consul_${CONSUL_VERSION}_linux_amd64.zip
CONSUL_URL=${URL:-https://releases.hashicorp.com/consul/${CONSUL_VERSION}/${CONSUL_ZIP}}
CONSUL_DIR=/usr/local/bin
CONSUL_PATH=${CONSUL_DIR}/consul
CONSUL_CONFIG_DIR=/etc/consul.d
CONSUL_DATA_DIR=/opt/consul/data
CONSUL_TLS_DIR=/opt/consul/tls
CONSUL_ENV_VARS=${CONSUL_CONFIG_DIR}/consul.conf
CONSUL_PROFILE_SCRIPT=/etc/profile.d/consul.sh
CONSUL_FLAGS="-dev -ui -client 0.0.0.0"

echo "Downloading Consul ${CONSUL_VERSION}"
[ 200 -ne $(curl --write-out %{http_code} --silent --output /tmp/${CONSUL_ZIP} ${CONSUL_URL}) ] && exit 1

echo "Installing Consul"
sudo unzip -o /tmp/${CONSUL_ZIP} -d ${CONSUL_DIR}
sudo chmod 0755 ${CONSUL_PATH}
sudo chown ${USER}:${GROUP} ${CONSUL_PATH}
echo "$(${CONSUL_PATH} --version)"

echo "Configuring Consul ${CONSUL_VERSION}"
sudo mkdir -pm 0755 ${CONSUL_CONFIG_DIR} ${CONSUL_DATA_DIR} ${CONSUL_TLS_DIR}

echo "Update directory permissions"
sudo chown -R ${USER}:${GROUP} ${CONSUL_CONFIG_DIR} ${CONSUL_DATA_DIR} ${CONSUL_TLS_DIR}
sudo chmod -R 0644 ${CONSUL_CONFIG_DIR}/*

echo "Set Consul profile script"
sudo tee ${CONSUL_PROFILE_SCRIPT} > /dev/null <<PROFILE
export CONSUL_HTTP_ADDR=http://127.0.0.1:8500
PROFILE

echo "Give consul user shell access for remote exec"
sudo /usr/sbin/usermod --shell /bin/bash ${USER} >/dev/null

echo "Allow consul sudo access for echo, tee, cat, sed, and systemctl"
sudo tee /etc/sudoers.d/consul > /dev/null <<SUDOERS
consul ALL=(ALL) NOPASSWD: /usr/bin/echo, /usr/bin/tee, /usr/bin/cat, /usr/bin/sed, /usr/bin/systemctl
SUDOERS

echo "Add prometheus and grafana service"
sudo mv /tmp/prometheus-service.json /etc/consul.d/prometheus.json
sudo mv /tmp/grafana-service.json /etc/consul.d/grafana-service.json

echo "Installing dnsmasq via yum"
sudo yum install -q -y dnsmasq

echo "Update resolv.conf"
sudo sed -i '1i nameserver 127.0.0.1\n' /etc/resolv.conf

echo "Configuring dnsmasq to forward .consul requests to consul port 8600"
sudo tee /etc/dnsmasq.d/consul > /dev/null <<DNSMASQ
server=/consul/127.0.0.1#8600
DNSMASQ

echo "Enable and restart dnsmasq"
sudo systemctl enable dnsmasq
sudo systemctl restart dnsmasq

echo "Systemd configuration"

sudo tee /etc/systemd/system/consul.service <<EOT
[Unit]
Description=Consul Agent
Requires=network-online.target
After=network-online.target

[Service]
Restart=on-failure
ExecStart=/usr/local/bin/consul agent ${CONSUL_FLAGS} -data-dir ${CONSUL_DATA_DIR} -config-dir /etc/consul.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
User=consul
Group=consul
Restart=on-failure
RestartSec=4

[Install]
WantedBy=multi-user.target
EOT
sudo chmod 0664 /etc/systemd/system/consul.service

sudo systemctl enable consul
sudo systemctl start consul

echo "Install Envoy, binary version"

[ -f getenvoy-envoy-${ENVOY_VERSION}.x86_64.rpm ] || wget -q https://tetrate.bintray.com/getenvoy-rpm/centos/7/x86_64/stable/Packages/getenvoy-envoy-${ENVOY_VERSION}.x86_64.rpm && \
sudo yum install -y ./getenvoy-envoy-${ENVOY_VERSION}.x86_64.rpm && \
sudo rm -f /usr/bin/envoy && sudo mv /opt/getenvoy/bin/envoy /usr/bin && chmod +x /usr/bin/envoy && \

echo "Install CNI plugins"

# install cni

if ${CNI_INSTALL}; then
    [ -f  cni-plugins-linux-amd64-v${CNI_VERSION}.tgz ] || wget -q https://github.com/containernetworking/plugins/releases/download/v${CNI_VERSION}/cni-plugins-linux-amd64-v${CNI_VERSION}.tgz && \
    sudo mkdir -p /opt/cni/bin && \
    sudo tar -C /opt/cni/bin -xzf cni-plugins-linux-amd64-v${CNI_VERSION}.tgz && \
    echo -e "net.bridge.bridge-nf-call-arptables = 1" | sudo tee /etc/sysctl.d/bridge.conf && \
    echo -e "net.bridge.bridge-nf-call-ip6tables = 1" | sudo tee -a /etc/sysctl.d/bridge.conf && \
    echo -e "net.bridge.bridge-nf-call-iptables = 1" | sudo tee -a /etc/sysctl.d/bridge.conf
fi

echo "Complete"
