#!/bin/bash
# Script to configure Arista cEOS routers after they start

# Wait for routers to be ready
echo -n "Waiting for cEOS routers to initialize"
for i in {1..30}; do
    echo -n "."
    sleep 5
    
    # Check if router1 is responsive
    if docker exec sine-lab-router1 Cli -c "show version" &>/dev/null; then
        echo -e "\nRouter 1 is initialized and ready."
        break
    fi
    
    # If we've waited too long, continue anyway
    if [ $i -eq 30 ]; then
        echo -e "\nTimeout waiting for routers to initialize. Continuing anyway..."
    fi
done

echo "Configuring Router 1..."
docker exec sine-lab-router1 Cli -c "
configure terminal
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
write memory
end
"

echo "Configuring Router 2..."
docker exec sine-lab-router2 Cli -c "
configure terminal
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
write memory
end
"

echo "Configuration of cEOS routers completed!"