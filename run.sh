#!/bin/bash
# Run script for the containerlab experiment with monitoring

# Deploy the lab
echo "Deploying containerlab topology..."
sudo containerlab deploy -t topology.yml

# Wait for the lab to be ready
echo "Waiting for the lab to be ready..."
sleep 10

# Configure the routers
echo "Configuring router1..."
sudo docker exec clab-sine-wave-lab-router1 vtysh -c "conf t" -c "int eth1" -c "ip address 10.1.1.2/24" -c "exit" -c "int eth2" -c "ip address 192.168.0.1/24" -c "exit" -c "int eth3" -c "ip address 172.30.0.1/24" -c "exit" -c "router ospf" -c "network 10.1.1.0/24 area 0" -c "network 192.168.0.0/24 area 0" -c "network 172.30.0.0/24 area 0" -c "exit" -c "exit"

echo "Configuring router2..."
sudo docker exec clab-sine-wave-lab-router2 vtysh -c "conf t" -c "int eth1" -c "ip address 192.168.0.2/24" -c "exit" -c "int eth2" -c "ip address 10.2.2.1/24" -c "exit" -c "router ospf" -c "network 192.168.0.0/24 area 0" -c "network 10.2.2.0/24 area 0" -c "exit" -c "exit"

# Configure the monitoring node
echo "Configuring monitoring node..."
sudo docker exec clab-sine-wave-lab-monitor ip address add 172.30.0.2/24 dev eth1
sudo docker exec clab-sine-wave-lab-monitor ip route add default via 172.30.0.1

# Install monitoring tools
echo "Installing monitoring stack..."
sudo docker exec clab-sine-wave-lab-monitor bash -c '
# Install SNMP exporter
mkdir -p /opt/snmp_exporter
cd /opt/snmp_exporter
wget https://github.com/prometheus/snmp_exporter/releases/download/v0.20.0/snmp_exporter-0.20.0.linux-arm64.tar.gz -O snmp_exporter.tar.gz
tar xvfz snmp_exporter.tar.gz --strip-components=1
nohup /opt/snmp_exporter/snmp_exporter --config.file=/etc/snmp_exporter/snmp.yml > /var/log/snmp_exporter.log 2>&1 &

# Install Prometheus
mkdir -p /opt/prometheus
cd /opt/prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.30.3/prometheus-2.30.3.linux-arm64.tar.gz -O prometheus.tar.gz
tar xvfz prometheus.tar.gz --strip-components=1
nohup /opt/prometheus/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/opt/prometheus/data > /var/log/prometheus.log 2>&1 &

# Install Grafana
apt-get update
apt-get install -y software-properties-common
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list
apt-get update
apt-get install -y grafana
systemctl daemon-reload
systemctl start grafana-server

# Install Homepage
apt-get install -y ca-certificates nodejs npm git
mkdir -p /opt/homepage
cd /opt/homepage
git clone https://github.com/gethomepage/homepage.git .
npm install
cp -r /app/config /opt/homepage/
cp -r /app/public/icons /opt/homepage/public/ || mkdir -p /opt/homepage/public/icons
# Download common icons
mkdir -p /opt/homepage/public/icons
wget -q https://raw.githubusercontent.com/gethomepage/homepage/main/public/icons/grafana.png -O /opt/homepage/public/icons/grafana.png
wget -q https://raw.githubusercontent.com/gethomepage/homepage/main/public/icons/prometheus.svg -O /opt/homepage/public/icons/prometheus.svg
wget -q https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/svg/router.svg -O /opt/homepage/public/icons/router.png
wget -q https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/svg/monitoring.svg -O /opt/homepage/public/icons/monitoring.png
wget -q https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/svg/networking.svg -O /opt/homepage/public/icons/networking.png
wget -q https://raw.githubusercontent.com/walkxcode/dashboard-icons/main/svg/vm.svg -O /opt/homepage/public/icons/host.png
# Start Homepage dashboard
PORT=3000 nohup npm run start > /var/log/homepage.log 2>&1 &
'

# Start SNMP on routers
echo "Starting SNMP on routers..."
sudo docker exec clab-sine-wave-lab-router1 service snmpd start
sudo docker exec clab-sine-wave-lab-router2 service snmpd start

# Start traffic generation scripts
echo "Starting traffic generation scripts..."
sudo docker exec -d clab-sine-wave-lab-host1 sh /host.sh
sudo docker exec -d clab-sine-wave-lab-host2 sh /host.sh

# Display information to monitor traffic
echo ""
echo "Traffic generation started in the background."
echo "Access Homepage at http://172.20.20.100:3001"
echo "Access Grafana at http://172.20.20.100:3000"
echo "Username: admin"
echo "Password: admin"
echo ""
echo "Access Prometheus at http://172.20.20.100:9090"
echo ""
echo "To manually check SNMP on routers:"
echo "sudo docker exec clab-sine-wave-lab-router1 snmpwalk -v2c -c public localhost IF-MIB::ifDescr"
echo ""
echo "To visualize network traffic in realtime from CLI:"
echo "sudo docker exec clab-sine-wave-lab-router1 apt-get update && sudo docker exec clab-sine-wave-lab-router1 apt-get install -y iftop"
echo "sudo docker exec -it clab-sine-wave-lab-router1 iftop -i eth1"
echo ""
echo "To destroy the lab: sudo containerlab destroy -t topology.yml"