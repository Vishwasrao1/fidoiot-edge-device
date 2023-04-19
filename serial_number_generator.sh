#!/bin/bash

for i in {1..10}; do
  client_id=$(printf "%02d" $i)
  serial_number="lxfdo$(printf "%03d" $i)VCW"
  filename="client${client_id}-manufacturer_sn.bin"
  echo -n "$serial_number" > "$filename"
done