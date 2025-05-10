#!/bin/sh
# Host 1 script to generate sine wave traffic pattern
apk add --no-cache coreutils bc python3

python3 -c '
import time
import math
import os
import subprocess
from datetime import datetime

# Target IP address - uses router as next hop
TARGET_IP = "10.2.2.2"
ROUTER_IP = "10.1.1.2"  # No need to add route, just use existing network

while True:
    # Calculate the sine wave value (0-100 range)
    t = time.time()
    amplitude = 50  # Base amplitude
    period = 60  # 1 minute period
    sine_value = amplitude + amplitude * math.sin(2 * math.pi * t / period)
    
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