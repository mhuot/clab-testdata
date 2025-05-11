#!/bin/bash
# Script to configure Arista cEOS routers after they start

# Wait for routers to be ready
echo -n "Waiting for cEOS routers to initialize"
for i in {1..30}; do
    echo -n "."
    sleep 5

    # Check if router1 is responsive by checking the flash directory
    if docker exec sine-lab-router1 ls -la /mnt/flash/ &>/dev/null; then
        echo -e "\nRouter 1 is initialized and ready."
        break
    fi

    # If we've waited too long, continue anyway
    if [ $i -eq 30 ]; then
        echo -e "\nTimeout waiting for routers to initialize. Continuing anyway..."
    fi
done

echo "Configuring Router 1..."
# Copy the startup-config from router1/config directly into the router's flash
docker cp ./router1/config/startup-config sine-lab-router1:/mnt/flash/startup-config

echo "Configuring Router 2..."
# Copy the startup-config from router2/config directly into the router's flash
docker cp ./router2/config/startup-config sine-lab-router2:/mnt/flash/startup-config

# Give the routers time to load the configs
sleep 10

echo "Configuration of cEOS routers completed!"