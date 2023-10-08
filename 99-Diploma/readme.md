```shell
terraform apply

declare -a IPS=(\"158.160.57.91\",192.168.10.32 \"158.160.57.233\",192.168.10.30 \"158.160.60.240\",192.168.10.26)

CONFIG_FILE=inventory/diploma/hosts.yml python3 contrib/inventory_builder/inventory.py ${IPS[@]}

ansible-playbook -i inventory/diploma/hosts.yml cluster.yml -b -v --user=ubuntu

```