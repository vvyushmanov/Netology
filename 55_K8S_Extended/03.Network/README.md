# Домашнее задание к занятию «Как работает сеть в K8s»

### Цель задания

Настроить сетевую политику доступа к подам.

----

### Задание 1. Создать сетевую политику или несколько политик для обеспечения доступа

1. Создать deployment'ы приложений frontend, backend и cache и соответсвующие сервисы.
2. В качестве образа использовать network-multitool.
3. Разместить поды в namespace App.
4. Создать политики, чтобы обеспечить доступ frontend -> backend -> cache. Другие виды подключений должны быть запрещены.
5. Продемонстрировать, что трафик разрешён и запрещён.

### Ответ

1. Манифесты

- [Backend](manifests/01-backend.yaml)
- [Frontend](manifests/02-frontend.yaml)
- [Cache](manifests/03-cache.yaml)
- [Allow fr->bk and bk->cache](manifests/04-allow-for-front-and-back.yaml)
- [Deny all other](manifests/05-policy-default-deny-ingress.yaml)

2. Проверка разрешения ингресса:

```shell
devops-netology/55_K8S_Extended/03.Network/manifests git:main  
❯ kubectl exec backend-6c9c77fbb4-wdqfh -- curl cache   
WBITT Network MultiTool (with NGINX) - cache-6c57d84c88-mvbzl - 10.1.125.211 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   139  100   139    0     0  52001      0 --:--:-- --:--:-- --:--:-- 69500
                                                                                                                               
devops-netology/55_K8S_Extended/03.Network/manifests git:main  
❯ kubectl exec frontend-689fc59f94-xbmtv -- curl backend 
WBITT Network MultiTool (with NGINX) - backend-6c9c77fbb4-wdqfh - 10.1.125.229 - HTTP: 80 , HTTPS: 443 . (Formerly praqma/network-multitool)
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   141  100   141    0     0  63858      0 --:--:-- --:--:-- --:--:--  137k
```

3. Проверка запрета остального трафика между подами

```shell
devops-netology/55_K8S_Extended/03.Network/manifests git:main  
❯ kubectl exec cache-6c57d84c88-mvbzl -- curl backend   
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:05 --:--:--     0^C
                                                                                                                               
devops-netology/55_K8S_Extended/03.Network/manifests git:main  6s
❯ kubectl exec cache-6c57d84c88-mvbzl -- curl frontend
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0     0    0     0    0     0      0      0 --:--:--  0:00:07 --:--:--     0^C
```
