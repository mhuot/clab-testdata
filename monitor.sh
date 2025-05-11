#\!/bin/bash
# Script to monitor router status and interfaces

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Checking router status...${NC}"

# Check if routers are running
if docker ps | grep -q sine-lab-router1; then
    echo -e "${GREEN}Router 1 is running${NC}"
    
    # Check interfaces on Router 1
    echo -e "\n${YELLOW}Router 1 interfaces:${NC}"

    # Create a temporary command file
    echo "enable
show ip interface brief" > /tmp/router1_cmd.txt
    # Execute it by sending the file to the container and running Cli with it
    docker cp /tmp/router1_cmd.txt sine-lab-router1:/tmp/cmd.txt
    docker exec sine-lab-router1 bash -c "Cli < /tmp/cmd.txt" || echo -e "${RED}Failed to get interface status${NC}"

    # Check routing table on Router 1
    echo -e "\n${YELLOW}Router 1 routing table:${NC}"
    echo "enable
show ip route" > /tmp/router1_cmd.txt
    docker cp /tmp/router1_cmd.txt sine-lab-router1:/tmp/cmd.txt
    docker exec sine-lab-router1 bash -c "Cli < /tmp/cmd.txt" || echo -e "${RED}Failed to get routing table${NC}"
else
    echo -e "${RED}Router 1 is not running${NC}"
fi

echo -e "\n"

if docker ps | grep -q sine-lab-router2; then
    echo -e "${GREEN}Router 2 is running${NC}"
    
    # Check interfaces on Router 2
    echo -e "\n${YELLOW}Router 2 interfaces:${NC}"

    # Create a temporary command file
    echo "enable
show ip interface brief" > /tmp/router2_cmd.txt
    # Execute it by sending the file to the container and running Cli with it
    docker cp /tmp/router2_cmd.txt sine-lab-router2:/tmp/cmd.txt
    docker exec sine-lab-router2 bash -c "Cli < /tmp/cmd.txt" || echo -e "${RED}Failed to get interface status${NC}"

    # Check routing table on Router 2
    echo -e "\n${YELLOW}Router 2 routing table:${NC}"
    echo "enable
show ip route" > /tmp/router2_cmd.txt
    docker cp /tmp/router2_cmd.txt sine-lab-router2:/tmp/cmd.txt
    docker exec sine-lab-router2 bash -c "Cli < /tmp/cmd.txt" || echo -e "${RED}Failed to get routing table${NC}"
else
    echo -e "${RED}Router 2 is not running${NC}"
fi

# Check connectivity between hosts
echo -e "\n${YELLOW}Checking connectivity from Host 1 to Host 2...${NC}"
docker exec sine-lab-host1 ping -c 3 10.2.2.2 || echo -e "${RED}Failed to ping Host 2 from Host 1${NC}"

echo -e "\n${YELLOW}Checking connectivity from Host 2 to Host 1...${NC}"
docker exec sine-lab-host2 ping -c 3 10.1.1.1 || echo -e "${RED}Failed to ping Host 1 from Host 2${NC}"

echo -e "\n${YELLOW}Active Docker containers:${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
