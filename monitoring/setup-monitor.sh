#!/bin/bash
# Setup script for monitoring container

# Set up the network
ip route add default via 172.30.0.1

# Install dependencies
apt-get update
apt-get install -y wget curl gnupg netcat software-properties-common git ca-certificates nodejs npm

# Install SNMP exporter
mkdir -p /opt/snmp_exporter
cd /opt/snmp_exporter
wget https://github.com/prometheus/snmp_exporter/releases/download/v0.20.0/snmp_exporter-0.20.0.linux-arm64.tar.gz -O snmp_exporter.tar.gz
tar xvfz snmp_exporter.tar.gz --strip-components=1
nohup /opt/snmp_exporter/snmp_exporter --config.file=/etc/snmp_exporter/snmp.yml > /var/log/snmp_exporter.log 2>&1 &

# Install Prometheus
mkdir -p /opt/prometheus /opt/prometheus/data
cd /opt/prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.30.3/prometheus-2.30.3.linux-arm64.tar.gz -O prometheus.tar.gz
tar xvfz prometheus.tar.gz --strip-components=1
nohup /opt/prometheus/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/opt/prometheus/data > /var/log/prometheus.log 2>&1 &

# Install Grafana
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list
apt-get update
apt-get install -y grafana
systemctl daemon-reload
systemctl start grafana-server

# Install Homepage
mkdir -p /opt/homepage
cd /opt/homepage
git clone https://github.com/gethomepage/homepage.git .
npm install
cp -r /app/config /opt/homepage/
mkdir -p /opt/homepage/public/icons

# Download common icons
wget -q https://raw.githubusercontent.com/gethomepage/homepage/main/public/icons/grafana.png -O /opt/homepage/public/icons/grafana.png
wget -q https://raw.githubusercontent.com/gethomepage/homepage/main/public/icons/prometheus.svg -O /opt/homepage/public/icons/prometheus.svg
wget -q https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/svg/router.svg -O /opt/homepage/public/icons/router.png
wget -q https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/svg/monitoring.svg -O /opt/homepage/public/icons/monitoring.png
wget -q https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/svg/networking.svg -O /opt/homepage/public/icons/networking.png
wget -q https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/svg/vm.svg -O /opt/homepage/public/icons/host.png

# Start Homepage dashboard
cd /opt/homepage
PORT=3000 npm run start

# Keep container running
tail -f /dev/null