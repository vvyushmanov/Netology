#!/bin/bash

set -e

root=$(pwd)

# Terraform
cd $root/10-terraform
terraform apply -auto-approve
cp ./hosts.yml $root/20-kubespray/inventory/diploma/
mainIP=$(terraform output -raw main-ip)

echo "========================================="

# Kubespray
cd $root/20-kubespray
ansible-playbook -i inventory/diploma/hosts.yml cluster.yml -b -v --user=ubuntu
echo "Copy new KubeConfig file to ~/.kube/config"
cp ./inventory/diploma/artifacts/admin.conf $HOME/.kube/config
echo "Wait for all kube-system components to be up"
kubectl wait --for=condition=Ready pod -n kube-system --all --timeout=900s

echo "========================================="

# Qbec
# Обновить IP адрес сервера из конфига
cd $root/30-k8s
./set-apiserver-ip.sh
qbec apply default --yes --wait

echo "Congrats! Cluster is fully operational"
echo "Open main page: http://$mainIP/"
echo "Grafana: http://$mainIP/grafana/"
