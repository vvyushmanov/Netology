#!/bin/bash

set -e

# Obtain IP address of the ApiServer from KubeConfig
server_line=$(grep 'server:' $HOME/.kube/config)
ip_address=$(echo "$server_line" | awk -F '//' '{print $2}' | cut -d ':' -f 1)
# Update IP address in qbec.yaml
sed -i "s/server: https:\/\/[0-9.]*:6443/server: https:\/\/$ip_address:6443/" ./qbec.yaml

echo "qbec ApiServer IP address set to: $ip_address"


