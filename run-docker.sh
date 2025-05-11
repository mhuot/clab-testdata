#!/bin/bash
# Script to run the Docker Compose based network lab with Arista cEOS

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Warning: .env file not found. Please create one from .env.template"
    echo "Using default image path or command line argument if provided."
fi

echo "Setting up Arista cEOS environment..."
if [ -n "$1" ]; then
    ./setup-arista.sh "$1"
else
    ./setup-arista.sh
fi

echo "Starting the sine wave network lab with Docker Compose..."
docker compose up -d

echo -e "\nWaiting for services to start (this may take up to 3 minutes)..."
echo "Arista cEOS devices can take some time to initialize..."

# Configure routers after they've started
./config-routers.sh

# Wait a bit to ensure traffic generation starts properly
sleep 10

echo -e "\nNetwork lab is up and running!"
echo ""
echo "Access the following services:"
echo "- Homepage Dashboard: http://localhost:3001"
echo "- Grafana: http://localhost:3000 (Username: admin, Password: admin)"
echo "- Prometheus: http://localhost:9090"
echo ""
echo "Access the Arista cEOS devices CLI:"
echo "- Router 1: ssh admin@localhost -p 2201 (password: admin)"
echo "- Router 2: ssh admin@localhost -p 2202 (password: admin)"
echo ""
echo "Access the Arista cEOS devices Web Interface:"
echo "- Router 1: http://localhost:8100"
echo "- Router 2: http://localhost:8101"
echo ""
echo "To view cEOS router logs:"
echo "docker logs sine-lab-router1"
echo ""
echo "To access cEOS CLI directly:"
echo "docker exec -it sine-lab-router1 Cli"
echo "docker exec -it sine-lab-router2 Cli"
echo ""
echo "To monitor router status:"
echo "./monitor.sh"
echo ""
echo "To stop the lab:"
echo "docker compose down"