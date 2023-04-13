#!/bin/bash

#Provision the device by running linux client
for num in $(seq -w 1 20); do
    docker exec edge-device_client$num sh -c "cd /opt/fdo/; ./linux-client" &
done
