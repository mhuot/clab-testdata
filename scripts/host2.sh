#!/bin/sh
# Host 2 script to generate offset sine wave traffic pattern
apk add --no-cache coreutils bc python3 iproute2

# Add route to reach Host1 through Router2
ip route add 172.20.0.0/24 via 172.30.0.2

python3 -c '
import time
import math
import os
import subprocess
from datetime import datetime

# Target IP address - uses router as next hop
TARGET_IP = "172.20.0.3"  # Host1 IP
ROUTER_IP = "172.30.0.2"  # Router2 IP in net3

while True:
    # Calculate the sine wave value (0-100 range) with phase offset
    t = time.time()
    amplitude = 50  # Base amplitude
    period = 60  # 1 minute period
    phase_offset = math.pi  # 180 degrees offset (opposite phase)
    sine_value = amplitude + amplitude * math.sin(2 * math.pi * t / period + phase_offset)
    
    # Round to integer packets
    packets = int(sine_value)
    
    # Log the value
    timestamp = datetime.now().strftime("%H:%M:%S")
    print(f"{timestamp} - Sending {packets} packets to {TARGET_IP}")
    
    # Send the traffic - ping with specific count
    if packets > 0:
        subprocess.run(["ping", "-c", str(packets), "-i", "0.2", TARGET_IP],
                      stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    # Sleep to maintain a consistent sample rate
    time.sleep(1)
'