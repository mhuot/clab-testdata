#!/bin/bash
# Script to run the Docker Compose based network lab with Arista cEOS

# Check if .env file exists
if [ ! -f .env ]; then
    echo "Error: .env file not found. Please create one from .env.template"
    echo "Run: cp .env.template .env"
    echo "Then edit .env to set CEOS_IMAGE_PATH and CEOS_VERSION"
    exit 1
fi

# Source the .env file to get the variables
source .env

# Allow command line override of the image path
if [ $# -eq 1 ]; then
    CEOS_IMAGE_PATH="$1"
    echo "Using image path from command line: $CEOS_IMAGE_PATH"
fi

# Check if CEOS_IMAGE_PATH is set
if [ -z "$CEOS_IMAGE_PATH" ]; then
    echo "Error: CEOS_IMAGE_PATH not set in .env file"
    exit 1
fi

# Check if CEOS_VERSION is set
if [ -z "$CEOS_VERSION" ]; then
    echo "Error: CEOS_VERSION not set in .env file"
    exit 1
fi

# Check if the cEOS image is already loaded in Docker
if docker images | grep -q "ceos.*${CEOS_VERSION}"; then
    echo "Arista cEOS image version ${CEOS_VERSION} is already loaded"
else
    echo "Loading Arista cEOS image..."
    
    # Check if the image file exists
    if [ ! -f "$CEOS_IMAGE_PATH" ]; then
        echo "Error: Image file not found at $CEOS_IMAGE_PATH"
        exit 1
    fi
    
    # Load the image
    echo "Importing cEOS image from $CEOS_IMAGE_PATH as ceos:${CEOS_VERSION}"
    docker import "$CEOS_IMAGE_PATH" "ceos:${CEOS_VERSION}"
    
    if [ $? -ne 0 ]; then
        echo "Error: Failed to import cEOS image"
        exit 1
    fi
    
    echo "Successfully loaded cEOS image"
fi

echo "Starting the network traffic lab with Docker Compose..."
docker compose up -d

echo -e "\nWaiting for services to start (this may take up to 3 minutes)..."
echo "Arista cEOS devices can take some time to initialize..."

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
echo "- Router 1: ssh arista@localhost -p 2201 (password: arista)"
echo "- Router 2: ssh arista@localhost -p 2202 (password: arista)"
echo ""
echo "To view cEOS router logs:"
echo "docker logs traffic-lab-router1"
echo ""
echo "To access cEOS CLI directly (interactive mode):"
echo "docker exec -it traffic-lab-router1 Cli"
echo "docker exec -it traffic-lab-router2 Cli"
echo ""
echo "To monitor router status:"
echo "./monitor.sh"
echo ""
echo "To stop the lab:"
echo "docker compose down"