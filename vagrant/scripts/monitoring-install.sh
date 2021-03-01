#! /bin/bash

set -ex

[ -f prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz ] || wget -q https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz && \
sudo useradd --no-create-home --shell /bin/false prometheus && \
sudo mkdir /etc/prometheus && \
sudo mv /tmp/prometheus.yml /etc/prometheus/prometheus.yml && \
sudo mkdir /var/lib/prometheus && \
sudo chown prometheus:prometheus /etc/prometheus && \
sudo chown prometheus:prometheus /var/lib/prometheus && \
sudo tar -xvzf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz && \
sudo mv prometheus-${PROMETHEUS_VERSION}.linux-amd64 prometheuspackage && \
sudo cp prometheuspackage/prometheus /usr/local/bin/ && \
sudo cp prometheuspackage/promtool /usr/local/bin/ && \
sudo chown prometheus:prometheus /usr/local/bin/prometheus && \
sudo chown prometheus:prometheus /usr/local/bin/promtool && \
sudo cp -r prometheuspackage/consoles /etc/prometheus && \
sudo cp -r prometheuspackage/console_libraries /etc/prometheus && \
sudo chown -R prometheus:prometheus /etc/prometheus/consoles && \
sudo chown -R prometheus:prometheus /etc/prometheus/console_libraries && \
sudo touch /etc/prometheus/prometheus.yml && \
sudo chown prometheus:prometheus /etc/prometheus/prometheus.yml && \
sudo tee /etc/systemd/system/prometheus.service <<EOT
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
--config.file /etc/prometheus/prometheus.yml \
--storage.tsdb.path /var/lib/prometheus/ \
--web.console.templates=/etc/prometheus/consoles \
--web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOT
sudo systemctl enable prometheus && \
sudo systemctl start prometheus && \
[ -f grafana-${GRAFANA_VERSION}.x86_64.rpm ] || wget -q https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.x86_64.rpm && \
sudo yum install -y grafana-${GRAFANA_VERSION}.x86_64.rpm && \
[ -f grafana-piechart-panel.zip ] || wget -q https://grafana.com/api/plugins/grafana-piechart-panel/versions/latest/download -O grafana-piechart-panel.zip && \
sudo unzip grafana-piechart-panel.zip -d /var/lib/grafana/plugins && \
[ -f natel-discrete-panel.zip ] || wget -q https://grafana.com/api/plugins/natel-discrete-panel/versions/latest/download -O natel-discrete-panel.zip && \
sudo unzip natel-discrete-panel.zip -d /var/lib/grafana/plugins && \
sudo mkdir /var/lib/grafana/dashboards && \
sudo mv /tmp/faasd.json /var/lib/grafana/dashboards/faasd.json && \
sudo mv /tmp/nomad-jobs.json /var/lib/grafana/dashboards/nomad-jobs.json && \
sudo mv /tmp/prometheus-ds.yaml /etc/grafana/provisioning/datasources/prometheus-ds.yaml && \
sudo mv /tmp/dashboard-provision.yaml /etc/grafana/provisioning/dashboards/dashboard-provision.yaml && \
sudo systemctl enable grafana-server && \
sudo systemctl start grafana-server
