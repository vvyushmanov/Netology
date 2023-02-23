# Самоконтроль выполненения задания

1. Где расположен файл с `some_fact` из второго пункта задания?
    *   Файл расположен по пути `group_vars/all/examp.yml`
2. Какая команда нужна для запуска вашего `playbook` на окружении `test.yml`?
    * Команда `ansible-playbook -i inventory/test.yml site.yml`
3. Какой командой можно зашифровать файл?
    * Командой `ansible-vault encrypt filename`
4. Какой командой можно расшифровать файл?
    * Командой `ansible-vault encrypt filename`
5. Можно ли посмотреть содержимое зашифрованного файла без команды расшифровки файла? Если можно, то как?
    * Командой `ansible-vault view filename`
6. Как выглядит команда запуска `playbook`, если переменные зашифрованы?
    * Выглядит так: `$ ansible-playbook -i inventory/prod.yml site.yml --ask-vault-pass`
7. Как называется модуль подключения к host на windows?
    *   ansible.builtin.winrm
8. Приведите полный текст команды для поиска информации в документации ansible для модуля подключений ssh
    * Команда `ansible-doc -t connection ssh`
9. Какой параметр из модуля подключения `ssh` необходим для того, чтобы определить пользователя, под которым необходимо совершать подключение?
    * Параметр `remote_user:`

### Дополнительные задания

1. При помощи `ansible-vault` расшифруйте все зашифрованные файлы с переменными.
    * Расшифровано
2. Зашифруйте отдельное значение `PaSSw0rd` для переменной `some_fact` паролем `netology`. Добавьте полученное значение в `group_vars/all/examp.yml`.
```yaml
---
  some_fact: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          63386164663434383635363535353961373763613431346365313932393232366130646566303732
          3933633739373465653266623166373937613335313037370a623462303762373264356438333833
          39626535653431623837666164383835643736306365653262393535353064383137646536393935
          6132356338663365630a653737313839396535663563336365326234326439653236653439616435
          3632
```
3. Запустите `playbook`, убедитесь, что для нужных хостов применился новый `fact`.
    * Выполнено
4. Добавьте новую группу хостов `fedora`, самостоятельно придумайте для неё переменную. В качестве образа можно использовать [этот](https://hub.docker.com/r/pycontribs/fedora).
```yaml
---
  el:
    hosts:
      centos7:
        ansible_connection: docker
  deb:
    hosts:
      ubuntu:
        ansible_connection: docker
  local:
    hosts:
      localhost:
        ansible_connection: local 
  fedora:
    hosts:
      fedora_pys:
        ansible_connection: docker
```
5. Напишите скрипт на bash: автоматизируйте поднятие необходимых контейнеров, запуск ansible-playbook и остановку контейнеров.
```shell
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
```
6. Все изменения должны быть зафиксированы и отправлены в вашей личный репозиторий.
    * Выполнено
