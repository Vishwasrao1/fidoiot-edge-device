#!/bin/bash
set -x
while inotifywait -e modify,create /opt/fdo/; do
  if [[ -f /opt/fdo/hawkbit.config ]]; then
    url=$(grep -Po "(?<=URL:)[^ ]*" /opt/fdo/hawkbit.config)
    controllerid=$(grep -Po "(?<=ControllerId:)[^ ]*" /opt/fdo/hawkbit.config)
    securitytoken=$(grep -Po "(?<=SecurityToken:)[^ ]*" /opt/fdo/hawkbit.config)
    /usr/bin/swupdate -v -k /hb-cert.crt -u "-t DEFAULT -x -u $url -i $controllerid -k $securitytoken" >> /opt/fdo/hawkbit.log 2>&1
  fi
done

