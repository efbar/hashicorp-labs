#!/bin/bash
set -x

echo "Vault user creation"

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

# Create & set permissions on HOME directory
sudo mkdir -pm 0755 ${HOME}
sudo chown -R ${USER}:${GROUP} ${HOME}
sudo chmod -R 0755 ${HOME}

echo "Vault install"

VAULT_VERSION=${VERSION}
VAULT_ZIP=vault_${VAULT_VERSION}_linux_amd64.zip
VAULT_URL=${URL:-https://releases.hashicorp.com/vault/${VAULT_VERSION}/${VAULT_ZIP}}
VAULT_DIR=/usr/local/bin
VAULT_PATH=${VAULT_DIR}/vault
VAULT_CONFIG_DIR=/etc/vault.d
VAULT_DATA_DIR=/opt/vault/data
VAULT_TLS_DIR=/opt/vault/tls
VAULT_ENV_VARS=${VAULT_CONFIG_DIR}/vault.conf
VAULT_PROFILE_SCRIPT=/etc/profile.d/vault.sh
VAULT_FLAGS="-dev -dev-ha -dev-transactional -dev-root-token-id=root -dev-listen-address=0.0.0.0:8200"

echo "Downloading Vault ${VAULT_VERSION}"
[ 200 -ne $(curl --write-out %{http_code} --silent --output /tmp/${VAULT_ZIP} ${VAULT_URL}) ] && exit 1

echo "Installing Vault"
sudo unzip -o /tmp/${VAULT_ZIP} -d ${VAULT_DIR}
sudo chmod 0755 ${VAULT_PATH}
sudo chown ${USER}:${GROUP} ${VAULT_PATH}
echo "$(${VAULT_PATH} --version)"

echo "Configuring Vault ${VAULT_VERSION}"
sudo mkdir -pm 0755 ${VAULT_CONFIG_DIR} ${VAULT_DATA_DIR} ${VAULT_TLS_DIR}

echo "Update directory permissions"
sudo chown -R ${USER}:${GROUP} ${VAULT_CONFIG_DIR} ${VAULT_DATA_DIR} ${VAULT_TLS_DIR}
sudo chmod -R 0644 ${VAULT_CONFIG_DIR}/*

echo "Set Vault profile script"
sudo tee ${VAULT_PROFILE_SCRIPT} > /dev/null <<PROFILE
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_TOKEN=root
PROFILE

echo "Granting mlock syscall to vault binary"
sudo setcap cap_ipc_lock=+ep ${VAULT_PATH}

echo "Vault systemd config"

sudo tee /etc/systemd/system/vault.service <<EOT
[Unit]
Description=Vault Agent

[Service]
Restart=on-failure
PermissionsStartOnly=true
ExecStartPre=/sbin/setcap 'cap_ipc_lock=+ep' /usr/local/bin/vault
ExecStart=/usr/local/bin/vault server -config /etc/vault.d ${VAULT_FLAGS}
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGTERM
User=vault
Group=vault
LimitMEMLOCK=infinity

[Install]
WantedBy=multi-user.target
EOT

sudo chmod 0664 /etc/systemd/system/vault.service

sudo systemctl enable vault
sudo systemctl start vault
