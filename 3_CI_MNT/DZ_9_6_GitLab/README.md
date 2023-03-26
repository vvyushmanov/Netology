# Домашнее задание к занятию 12 «GitLab»

## Итог

В качестве ответа пришлите подробные скриншоты по каждому пункту задания:

1. Файл gitlab-ci.yml;

![Alt text](img/1.png)

Полный файл можно посмотреть [здесь](./gitlab-ci.yml)

2. Dockerfile; 

![Alt text](img/2.png)

Полный файл можно посмотреть [здесь](./dockerfile)

3. Лог успешного выполнения пайплайна;

Build:
![Alt text](img/3.png)

--> [Лог целиком](./build.log) <--

Deploy:
![Alt text](img/4.png)

--> [Лог целиком](./deploy.log) <--

4. Решённый Issue

- Создание
![Alt text](img/5_creation.png)

- Merge request
![Alt text](img/6_mr.png)

- Merged
![Alt text](img/7_merged.png)

- Тест
![Alt text](img/8_test.png)

- Закрытый issue
![Alt text](img/9_closed.png)

![Alt text](img/10_comments.png)

## Дополнительное задание

Для того, чтобы протестировать успешный запуск контейнера и отображение ожидаемого сообщения, файл `gitlab-ci.yml` необходимо дополнить следующим образом:

``` yml
stages:
  - build
  - deploy
  - test

# ...
# build and deploy stages.......
# ...

test:
  image: gcr.io/cloud-builders/kubectl:latest
  stage: test
  script:
    - kubectl config set-cluster k8s --server="$KUBE_URL" --insecure-skip-tls-verify=true
    - kubectl config set-credentials admin --token="$KUBE_TOKEN"
    - kubectl config set-context default --cluster=k8s --user=admin
    - kubectl config use-context default
    - sed -i "s/__VERSION__/latest/" k8s.yaml
    - kubectl apply -f k8s.yaml
    - IP=$(kubectl get pod -n python-api --selector=app=python-api --output=jsonpath='{.items[0].status.podIP}')
    - response=$(curl -X GET http://$IP:5290/get_info)
    - echo $response
    - echo $response | grep "Running" || exit 1
  only:
    - main
```
