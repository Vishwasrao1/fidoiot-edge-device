#!/bin/bash

#Provision the device by running linux client
docker exec edge-device_client01 sh -c "cd /opt/fdo/; ./linux-client"
docker exec edge-device_client02 sh -c "cd /opt/fdo/; ./linux-client"
docker exec edge-device_client03 sh -c "cd /opt/fdo/; ./linux-client"
docker exec edge-device_client04 sh -c "cd /opt/fdo/; ./linux-client"