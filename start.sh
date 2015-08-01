#!/bin/sh
while [ 0 -lt 1 ]
do
    ./piepan -username="Anjelica" -server="127.0.0.1:64738" -insecure=true -certificate="keys/anjelica.crt" -key="keys/anjelica.key" anjelica.lua
done
