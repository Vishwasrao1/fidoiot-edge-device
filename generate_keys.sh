#!/bin/bash

# generate ecdsa384privkey
cd /opt/fdo/data/ 
openssl ecparam -name secp384r1 -genkey -noout -out key.pem
PRIVATE_KEY_HEX=$(openssl asn1parse -inform PEM -in key.pem | grep "OCTET STRING" | awk -F: '{print $NF}' | tr -d '[:space:]') 
echo $PRIVATE_KEY_HEX | xxd -r -p > ecdsa384privkey.dat
mv key.pem ecdsa384privkey.pem 
