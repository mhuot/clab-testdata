#!/bin/bash
# Script to load the Arista cEOS image and prepare the environment

# Source environment variables if the file exists
if [ -f .env ]; then
    source .env
fi

# Check if CEOS_IMAGE_PATH is set via environment variable or argument
if [ -n "$1" ]; then
    CEOS_IMAGE_PATH="$1"
elif [ -z "$CEOS_IMAGE_PATH" ]; then
    echo "Error: CEOS_IMAGE_PATH environment variable not set and no image path provided as argument."
    echo "Usage: $0 /path/to/ceos-image.tar"
    echo "Or set CEOS_IMAGE_PATH in .env file."
    exit 1
fi

# Get version from environment variable or default to 4.33.1
CEOS_VERSION=${CEOS_VERSION:-4.33.1}

# Check if the Arista cEOS image is already loaded
if docker image inspect ceos:${CEOS_VERSION} &>/dev/null; then
    echo "Arista cEOS image ceos:${CEOS_VERSION} is already loaded."
else
    # Check if the file exists
    if [ ! -f "$CEOS_IMAGE_PATH" ]; then
        echo "Error: Arista cEOS image not found at $CEOS_IMAGE_PATH"
        exit 1
    fi

    echo "Loading Arista cEOS image from $CEOS_IMAGE_PATH..."
    # Check if it's an XZ compressed file
    if [[ "$CEOS_IMAGE_PATH" == *.xz ]]; then
        echo "Detected .xz compression, decompressing and importing..."
        unxz -c "$CEOS_IMAGE_PATH" > /tmp/ceos-extracted.tar
        echo "Importing image as ceos:${CEOS_VERSION}..."
        docker image import /tmp/ceos-extracted.tar ceos:${CEOS_VERSION}
        rm -f /tmp/ceos-extracted.tar
    elif [[ "$CEOS_IMAGE_PATH" == *.tar ]]; then
        echo "Importing image as ceos:${CEOS_VERSION}..."
        docker image import "$CEOS_IMAGE_PATH" ceos:${CEOS_VERSION}
    else
        echo "Error: Unsupported file format. Please provide a .tar or .tar.xz file."
        exit 1
    fi

    # Verify the image was loaded
    if docker image inspect ceos:${CEOS_VERSION} &>/dev/null; then
        echo "Successfully loaded image ceos:${CEOS_VERSION}"
    else
        echo "Error: Failed to load the cEOS image"
        exit 1
    fi
fi

echo "Creating startup configurations for cEOS devices..."

# Create config directories
mkdir -p ./router1/config
mkdir -p ./router2/config

# Create startup config for Router 1
cat > ./router1/config/startup-config << 'EOF'
! Startup configuration for Router 1
hostname router1
!
spanning-tree mode mstp
!
no aaa root
!
interface Ethernet1
   description Connection to Host1
   no switchport
   ip address 10.1.1.2/24
!
interface Ethernet2
   description Connection to Router2
   no switchport
   ip address 192.168.0.1/24
!
interface Ethernet3
   description Connection to Monitoring
   no switchport
   ip address 172.30.0.1/24
!
interface Management0
   ip address 192.168.100.10/24
!
ip routing
!
ip route 10.2.2.0/24 192.168.0.2
!
! SNMP Configuration
snmp-server community public ro
snmp-server vrf default
!
! Allow connections
management api http-commands
   no shutdown
!
end
EOF

# Create startup config for Router 2
cat > ./router2/config/startup-config << 'EOF'
! Startup configuration for Router 2
hostname router2
!
spanning-tree mode mstp
!
no aaa root
!
interface Ethernet1
   description Connection to Router1
   no switchport
   ip address 192.168.0.2/24
!
interface Ethernet2
   description Connection to Host2
   no switchport
   ip address 10.2.2.1/24
!
interface Management0
   ip address 192.168.100.11/24
!
ip routing
!
ip route 10.1.1.0/24 192.168.0.1
!
! SNMP Configuration
snmp-server community public ro
snmp-server vrf default
!
! Allow connections
management api http-commands
   no shutdown
!
end
EOF

echo "Setup complete - Arista cEOS images and configurations are ready"