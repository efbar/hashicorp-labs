#!/bin/bash
set -x

echo "Nomad Install"

NOMAD_VERSION=${VERSION}
NOMAD_ZIP=nomad_${NOMAD_VERSION}_linux_amd64.zip
NOMAD_URL=${URL:-https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/${NOMAD_ZIP}}
NOMAD_DIR=/usr/local/bin
NOMAD_PATH=${NOMAD_DIR}/nomad
NOMAD_CONFIG_DIR=/etc/nomad.d
NOMAD_DATA_DIR=/opt/nomad/data
NOMAD_TLS_DIR=/opt/nomad/tls
NOMAD_ENV_VARS=${NOMAD_CONFIG_DIR}/nomad.conf
NOMAD_PROFILE_SCRIPT=/etc/profile.d/nomad.sh
NOMAD_FLAGS="-dev -bind 0.0.0.0"
GROUP="${GROUP:-}"
USER="${USER:-}"
COMMENT="${COMMENT:-}"
HOME="${HOME:-}"

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

echo "Downloading Nomad ${NOMAD_VERSION}"
[ 200 -ne $(curl --write-out %{http_code} --silent --output /tmp/${NOMAD_ZIP} ${NOMAD_URL}) ] && exit 1

echo "Installing Nomad"
sudo unzip -o /tmp/${NOMAD_ZIP} -d ${NOMAD_DIR}
sudo chmod 0755 ${NOMAD_PATH}
sudo chown ${USER}:${GROUP} ${NOMAD_PATH}
echo "$(${NOMAD_PATH} --version)"

echo "Configuring Nomad ${NOMAD_VERSION}"
sudo mkdir -pm 0755 ${NOMAD_CONFIG_DIR} ${NOMAD_DATA_DIR} ${NOMAD_TLS_DIR}

echo "Update directory permissions"
sudo chown -R ${USER}:${GROUP} ${NOMAD_CONFIG_DIR} ${NOMAD_DATA_DIR} ${NOMAD_TLS_DIR}
sudo chmod -R 0644 ${NOMAD_CONFIG_DIR}/*

echo "Set Nomad profile script"
sudo tee ${NOMAD_PROFILE_SCRIPT} > /dev/null <<PROFILE
export NOMAD_ADDR=http://127.0.0.1:4646
PROFILE

sudo tee /etc/systemd/system/nomad.service <<EOT
[Unit]
Description=Nomad Agent
Requires=consul.service

[Service]
Restart=on-failure
ExecStart=/usr/local/bin/nomad agent -config /etc/nomad.d ${NOMAD_FLAGS}
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOT

sudo chmod 0664 /etc/systemd/system/nomad.service

consul_up=$(curl --silent --output /dev/null --write-out "%{http_code}" "127.0.0.1:8500/v1/status/leader") || consul_up=""

while [ $(curl --silent --output /dev/null --write-out "%{http_code}" "127.0.0.1:8500/v1/status/leader") != "200" ]; do
  echo "Waiting for Consul to get a leader..."
  sleep 5
  consul_up=$(curl --silent --output /dev/null --write-out "%{http_code}" "127.0.0.1:8500/v1/status/leader") || consul_up=""
done

sudo systemctl enable nomad
sudo systemctl start nomad

echo "Complete"