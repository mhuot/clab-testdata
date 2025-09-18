#!/bin/sh
# Host 1 script - Bursty traffic pattern generator using iperf3

# Install required packages
apk add --no-cache iperf3 iproute2

# Add route to reach Host2 through Router1
ip route add 172.30.0.0/24 via 172.20.0.1

# Wait for network to be ready
sleep 5

# Start iperf3 server in the background (for receiving traffic)
iperf3 -s -D

# Function to generate bursty traffic
generate_bursty_traffic() {
    TARGET_IP="172.30.0.3"  # Host2 IP
    
    while true; do
        # Burst period - high bandwidth for 10-20 seconds
        BURST_DURATION=$((10 + RANDOM % 11))
        BANDWIDTH=$((50 + RANDOM % 51))  # 50-100 Mbps
        
        echo "$(date '+%H:%M:%S') - Starting burst: ${BANDWIDTH}Mbps for ${BURST_DURATION}s to $TARGET_IP"
        iperf3 -c $TARGET_IP -t $BURST_DURATION -b ${BANDWIDTH}M -p 5201 2>/dev/null
        
        # Idle period - minimal or no traffic for 5-15 seconds
        IDLE_DURATION=$((5 + RANDOM % 11))
        echo "$(date '+%H:%M:%S') - Idle period for ${IDLE_DURATION}s"
        sleep $IDLE_DURATION
        
        # Occasional longer quiet period (simulating off-hours)
        if [ $((RANDOM % 10)) -eq 0 ]; then
            LONG_IDLE=$((30 + RANDOM % 31))
            echo "$(date '+%H:%M:%S') - Extended idle period for ${LONG_IDLE}s"
            sleep $LONG_IDLE
        fi
    done
}

# Start generating traffic
generate_bursty_traffic