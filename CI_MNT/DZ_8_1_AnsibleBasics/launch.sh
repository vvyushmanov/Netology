#!/bin/bash

docker start centos7 || docker run -it -d --name "centos7" centos:7
docker start ubuntu || docker run -it -d --name "ubuntu" ubuntu:latest
docker start fedora_pys || docker run -it -d --name "fedora_pys" pycontribs/fedora
docker exec -it ubuntu bash -c "python3 --version" || \
    docker exec -it ubuntu bash -c "apt update && apt install -y python3"
ansible-playbook -i inventory/prod.yml site.yml --ask-vault-password
docker stop centos7
docker stop ubuntu
docker stop fedora_pys