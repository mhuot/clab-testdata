#!/bin/sh
# Host 2 script - Steady baseline with periodic spikes traffic pattern using iperf3

# Install required packages
apk add --no-cache iperf3 iproute2

# Add route to reach Host1 through Router2
ip route add 172.20.0.0/24 via 172.30.0.1

# Wait for network to be ready
sleep 5

# Start iperf3 server in the background (for receiving traffic)
iperf3 -s -D

# Function to generate steady traffic with spikes
generate_steady_with_spikes() {
    TARGET_IP="172.20.0.3"  # Host1 IP
    BASELINE_BW="10M"       # Steady 10 Mbps baseline
    
    while true; do
        # Determine if this is a spike period (20% chance)
        if [ $((RANDOM % 5)) -eq 0 ]; then
            # Spike period - simulate large transfer
            SPIKE_BW=$((80 + RANDOM % 41))  # 80-120 Mbps
            SPIKE_DURATION=$((5 + RANDOM % 11))  # 5-15 seconds
            
            echo "$(date '+%H:%M:%S') - Traffic spike: ${SPIKE_BW}Mbps for ${SPIKE_DURATION}s to $TARGET_IP"
            iperf3 -c $TARGET_IP -t $SPIKE_DURATION -b ${SPIKE_BW}M -p 5201 2>/dev/null
        else
            # Normal period - steady baseline traffic
            NORMAL_DURATION=$((15 + RANDOM % 16))  # 15-30 seconds
            
            echo "$(date '+%H:%M:%S') - Baseline traffic: ${BASELINE_BW}bps for ${NORMAL_DURATION}s to $TARGET_IP"
            iperf3 -c $TARGET_IP -t $NORMAL_DURATION -b $BASELINE_BW -p 5201 2>/dev/null
        fi
        
        # Small gap between sessions (1-3 seconds)
        GAP=$((1 + RANDOM % 3))
        sleep $GAP
    done
}

# Start generating traffic
generate_steady_with_spikes