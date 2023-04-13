#!/bin/bash

#Run the client
for num in $(seq -w 1 20); do
    docker exec edge-device_client$num sh -c "cd /opt/fdo/; ./linux-client" 
done
