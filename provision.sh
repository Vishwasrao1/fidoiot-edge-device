#!/bin/bash

# Provision the device by running linux client
for num in $(seq -w 1 10); do
    output_file="latency/edge-device_client$num"
    { time docker exec edge-device_client$num sh -c "cd /opt/fdo/; ./linux-client"; } 2> "$output_file" &
done

