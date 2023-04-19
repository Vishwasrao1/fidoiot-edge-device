#!/bin/bash
for i in {1..10}
do
    s=$(printf "lxfdo%03dVCW" $i)
    bash extend_upload.sh -e mtls -c ./secrets -s $s
done