# Sine Wave Network Traffic Lab

This project creates a network topology with two hosts connected through two Arista cEOS routers. The hosts generate traffic in a sine wave pattern, with the traffic patterns offset by 180 degrees. The lab includes monitoring with Homepage, Grafana, Prometheus, and SNMP Exporter for visualizing the traffic patterns.

## Prerequisites

- Docker installed
- Docker Compose installed
- Arista cEOS ARM image (path specified in `.env` file or as a command line argument)
- No special permissions needed - runs entirely on Docker for Mac

## Environment Setup

The lab uses environment variables to specify the location and version of the Arista cEOS image:

1. Copy the template environment file:
   ```bash
   cp .env.template .env
   ```

2. Edit the `.env` file to set the path to your Arista cEOS image:
   ```
   CEOS_IMAGE_PATH=/path/to/your/cEOSarm-lab-image.tar
   CEOS_VERSION=4.33.1
   ```

**Note:** The `.env` file is excluded from version control to avoid sharing sensitive or system-specific information.

## Architecture

```
                +------------+    +--------------+    +-----------+    +------------+
                |   Grafana  |    |  Prometheus  |    |    SNMP   |    |  Homepage  |
                |  Dashboard |    |    Server    |    |  Exporter  |    | Dashboard |
                +------------+    +--------------+    +-----------+    +------------+
                      |                 |                  |                 |
                      |                 |                  |                 |
                      +-----------------+------------------+-----------------+
                                                |
                                                | (Monitoring Network)
                                                |
                            +------------------------------------------+
                            |                                          |
                            |                                          |
                +-----------+-------------+            +---------------+-----------+
                |      Arista cEOS        |            |       Arista cEOS         |
                | (10.1.1.2, 192.168.0.1) |            | (192.168.0.2, 10.2.2.1)  |
                +-----------+-------------+            +---------------+-----------+
                            |                                          |
                            |                                          |
                      +-----+------+                            +------+-----+
                      |   Host 1   |                            |   Host 2   |
                      | (10.1.1.1) |                            | (10.2.2.2) |
                      +------------+                            +------------+
```

The topology consists of:
- Two hosts (host1 and host2) running Alpine Linux
- Two routers (router1 and router2) running Arista cEOS
- Four monitoring containers:
  - Grafana for visualization
  - Prometheus for metrics collection
  - SNMP Exporter for network metrics
  - Homepage dashboard for easy access to all services

## Usage

1. Run the lab using Docker Compose (with the image path from the `.env` file):

```bash
./run-docker.sh
```

Alternatively, specify the image path directly:

```bash
./run-docker.sh /path/to/cEOSarm-lab-image.tar
```

This will:
- Check if the Arista cEOS image is already loaded, and load it if needed
- Prepare router configurations
- Start all containers using Docker Compose
- Configure the routers with IP routing
- Start the traffic generation scripts on both hosts

2. Monitor the status of the routers and connectivity:

```bash
./monitor.sh
```

This will:
- Check if both routers are running
- Display interfaces and routing tables for both routers
- Test connectivity between hosts
- Show active Docker containers

3. Access Monitoring Dashboards:

- Homepage Dashboard: http://localhost:3001
- Grafana: http://localhost:3000 (Username: admin, Password: admin)
- Prometheus: http://localhost:9090

4. Access Arista cEOS Devices:

- Router 1 Web Interface: http://localhost:8000
- Router 2 Web Interface: http://localhost:8001
- Router 1 SSH: `ssh admin@localhost -p 2001` (password: admin)
- Router 2 SSH: `ssh admin@localhost -p 2002` (password: admin)
- Direct CLI access: `docker exec -it sine-lab-router1 Cli`

5. Destroy the lab when done:

```bash
docker compose down
```

## Traffic Generation

The hosts generate traffic in sine wave patterns:
- host1 generates a sine wave pattern with a 60-second period
- host2 generates a sine wave pattern offset by 180 degrees (completely out of phase)

This creates an interesting visualization in the monitoring dashboards, with inbound and outbound traffic showing inverse patterns.

## Monitoring Stack

The monitoring infrastructure includes:
- **Homepage**: Modern dashboard for accessing all services in one place
- **Grafana**: Dashboard visualization tool
- **Prometheus**: Time series database for storing metrics
- **SNMP Exporter**: Collects SNMP metrics from routers

The routers are configured with SNMP to provide interface traffic statistics that are collected by the monitoring stack.

## Files

- `docker-compose.yml` - Docker Compose configuration for all services
- `run-docker.sh` - Script to start the lab
- `monitor.sh` - Script to check router status and connectivity
- `setup-arista.sh` - Script to load the Arista cEOS image and prepare configurations
- `.env.template` - Template for environment variables file
- `.env` - Environment variables file (not included in version control)
- `.gitignore` - Specifies files to exclude from version control
- `scripts/host1.sh` & `scripts/host2.sh` - Traffic generation scripts
- `router1/config/startup-config` - Arista cEOS Router 1 configuration
- `router2/config/startup-config` - Arista cEOS Router 2 configuration
- `monitoring/` - Monitoring configuration files
  - `prometheus/prometheus.yml` - Prometheus configuration
  - `snmp_exporter/snmp.yml` - SNMP Exporter configuration
  - `grafana/provisioning/` - Grafana provisioning configs
  - `grafana/dashboards/` - Grafana dashboards
  - `homepage/config/` - Homepage configuration
    - `settings.yaml` - General settings
    - `services.yaml` - Service definitions
    - `widgets.yaml` - Dashboard widgets
    - `docker.yaml` - Docker integration

## ARM Compatibility

This lab is designed to work on ARM-based systems like Apple Silicon Macs, using the Arista cEOS ARM image and multi-architecture containers for all other services.