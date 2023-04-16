#!/bin/bash

# Wait for hawkbit.config to be created
while [[ ! -f /opt/fdo/hawkbit.config ]]; do
  sleep 1
done

while true; do
  # wait for file modification
  inotifywait -e modify,create /opt/fdo/hawkbit.config
  if [[ -f /opt/fdo/hawkbit.config ]]; then
      # execute command if file contents have changed
      url=$(grep -Po "(?<=URL:)[^ ]*" /opt/fdo/hawkbit.config)
      controllerid=$(grep -Po "(?<=ControllerId:)[^ ]*" /opt/fdo/hawkbit.config)
      securitytoken=$(grep -Po "(?<=SecurityToken:)[^ ]*" /opt/fdo/hawkbit.config)
      
      # check if all values are non-empty and valid
      if [[ -n "$url" && -n "$controllerid" && -n "$securitytoken" && "$securitytoken" =~ ^[a-z0-9]{32}$ ]]; then
        timestamp=$(date +%Y-%m-%d_%H:%M:%S)
        echo "Hawkbit config changed at $timestamp" >> /opt/fdo/hawkbit.log
        set -x
        /usr/bin/swupdate -v -k /hb-cert.crt -u "-t DEFAULT -x -u $url -i $controllerid -k $securitytoken" >> /opt/fdo/hawkbit.log 2>&1
      else
        echo "Error: missing or invalid configuration values" >> /opt/fdo/hawkbit.log
      fi
    # add a delay before checking for the next file modification event
    sleep 10
  fi
done
