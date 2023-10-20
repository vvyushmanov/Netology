#!/bin/bash

set -e

root=$(pwd)

# Terraform
cd $root/10-terraform
terraform apply -target=yandex_vpc_subnet.public-a \
     -target=yandex_vpc_subnet.public-b \
     -target=yandex_vpc_subnet.public-c -auto-approve
terraform apply -auto-approve
cp ./hosts.yml $root/20-kubespray/inventory/diploma/
mainIP=$(terraform output -raw main-ip)

echo "========================================="

# Kubespray
cd $root/20-kubespray
ansible-playbook -i inventory/diploma/hosts.yml scale.yml -b -v --user=ubuntu
echo "Wait for all kube-system components to be up"
kubectl wait --for=condition=Ready pod -n kube-system --all --timeout=900s

echo "========================================="


echo "Congrats! Cluster is fully operational"
echo "Open main page: http://$mainIP/"
echo "Grafana: http://$mainIP/grafana/"
