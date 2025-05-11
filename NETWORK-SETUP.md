# Network Setup Documentation

## Network Architecture

This lab environment consists of the following components:

1. **Router1 (cEOS)** - Main router connecting Host1 to the network
   - Interfaces:
     - Management0: 192.168.100.2/24 (OOB network)
     - Ethernet1: 172.10.0.3/24 (connection to Router2)
     - Ethernet2: 172.20.0.2/24 (connection to Host1)
   - Routes:
     - 172.30.0.0/24 via 172.10.0.2 (to access Host2 network)

2. **Router2 (cEOS)** - Secondary router connecting Host2 to the network
   - Interfaces:
     - Management0: 192.168.100.3/24 (OOB network)
     - Ethernet1: 172.10.0.2/24 (connection to Router1)
     - Ethernet2: 172.30.0.2/24 (connection to Host2 and monitoring)
   - Routes:
     - 172.20.0.0/24 via 172.10.0.3 (to access Host1 network)

3. **Host1** - Generates sine wave traffic pattern
   - Network: 172.20.0.0/24 (net2)
   - IP: 172.20.0.3/24
   - Default route: via 172.20.0.2 (Router1)
   - SSH access: Port 2221 on host
   - Credentials: root/password

4. **Host2** - Generates offset sine wave traffic pattern
   - Network: 172.30.0.0/24 (net3)
   - IP: 172.30.0.3/24
   - Default route: via 172.30.0.2 (Router2)
   - SSH access: Port 2222 on host
   - Credentials: root/password

5. **Monitoring Services**
   - All on network 172.30.0.0/24 (net3)
   - Grafana (172.30.0.10): Port 3000
   - Prometheus (172.30.0.11): Port 9090
   - SNMP Exporter (172.30.0.12): Port 9116
   - Homepage (172.30.0.13): Port 3001

## Docker Networks

| Network        | Subnet          | Purpose                            |
|----------------|-----------------|-----------------------------------|
| OOB            | 192.168.100.0/24| Management network                |
| net1           | 172.10.0.0/24   | Router interconnect               |
| net2           | 172.20.0.0/24   | Host1 to Router1 connection       |
| net3           | 172.30.0.0/24   | Host2 and monitoring connections  |

## Environment Variables

The lab uses the following environment variables:
- CEOS_IMAGE_PATH: Path to the cEOS image file
- CEOS_VERSION: Version tag for the cEOS image (e.g., 4.33.1)

## Accessing the Lab

1. **Router CLI**:
   - Router1: `docker exec -it sine-lab-router1 Cli`
   - Router2: `docker exec -it sine-lab-router2 Cli`

2. **SSH Access**:
   - Router1: `ssh -p 2201 admin@localhost` (Default password: arista)
   - Router2: `ssh -p 2202 admin@localhost` (Default password: arista)
   - Host1: `ssh -p 2221 root@localhost` (Password: password)
   - Host2: `ssh -p 2222 root@localhost` (Password: password)

3. **Web Interfaces**:
   - Router1 GUI: http://localhost:8100
   - Router2 GUI: http://localhost:8101
   - Grafana: http://localhost:3000 (admin/admin)
   - Prometheus: http://localhost:9090
   - Homepage: http://localhost:3001

## Traffic Generation

The hosts generate synthetic network traffic in a sine wave pattern:
- Host1 generates a standard sine wave pattern
- Host2 generates a 180° phase-shifted sine wave pattern (opposite of Host1)
- This creates a distinctive visual pattern in the traffic graphs

## Monitoring

SNMP monitoring is configured to collect interface statistics from both routers.
The Grafana dashboard displays the traffic patterns, showing the sine wave effect.