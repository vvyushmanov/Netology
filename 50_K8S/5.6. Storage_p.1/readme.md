# Домашнее задание к занятию «Хранение в K8s. Часть 1»

### Цель задания

В тестовой среде Kubernetes нужно обеспечить обмен файлами между контейнерам пода и доступ к логам ноды.

### Задание 1 

**Что нужно сделать**

Создать Deployment приложения, состоящего из двух контейнеров и обменивающихся данными.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Сделать так, чтобы busybox писал каждые пять секунд в некий файл в общей директории.
3. Обеспечить возможность чтения файла контейнером multitool.
4. Продемонстрировать, что multitool может читать файл, который периодоически обновляется.
5. Предоставить манифесты Deployment в решении, а также скриншоты или вывод команды из п. 4.

### Ответ

```shell
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.6. Storage_p.1 on main]
$ kubectl exec -it filereader-55484f99d4-2l7wn -c multitool -- tail -f /input/test.txt1
04.07.2023 21:21:53: Hello, Netology!
04.07.2023 21:21:58: Hello, Netology!
04.07.2023 21:22:03: Hello, Netology!
04.07.2023 21:22:08: Hello, Netology!
04.07.2023 21:22:13: Hello, Netology!
04.07.2023 21:22:18: Hello, Netology!
04.07.2023 21:22:23: Hello, Netology!
```

[Манифест](task1.yml)

------

### Задание 2

**Что нужно сделать**

Создать DaemonSet приложения, которое может прочитать логи ноды.

1. Создать DaemonSet приложения, состоящего из multitool.
2. Обеспечить возможность чтения файла `/var/log/syslog` кластера MicroK8S.
3. Продемонстрировать возможность чтения файла изнутри пода.
4. Предоставить манифесты Deployment, а также скриншоты или вывод команды из п. 2.

### Ответ

```shell
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.6. Storage_p.1 on main]
$ kubectl exec -it node-logger-wrp55 -- tail -f /logger/syslog 1
Jul  5 01:30:47 vyushmanov-GL703VD microk8s.daemon-kubelite[6102]: I0705 01:30:47.403935    6102 handler.go:232] Adding GroupVersion crd.projectcalico.org v1 to ResourceManager
Jul  5 01:30:47 vyushmanov-GL703VD microk8s.daemon-kubelite[6102]: I0705 01:30:47.404291    6102 handler.go:232] Adding GroupVersion crd.projectcalico.org v1 to ResourceManager
Jul  5 01:30:47 vyushmanov-GL703VD microk8s.daemon-kubelite[6102]: I0705 01:30:47.404582    6102 handler.go:232] Adding GroupVersion crd.projectcalico.org v1 to ResourceManager
...
```

[Манифест](task2.yml)




