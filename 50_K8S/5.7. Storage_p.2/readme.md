# Домашнее задание к занятию «Хранение в K8s. Часть 2»

### Цель задания

В тестовой среде Kubernetes нужно создать PV и продемострировать запись и хранение файлов.

### Задание 1

**Что нужно сделать**

Создать Deployment приложения, использующего локальный PV, созданный вручную.

1. Создать Deployment приложения, состоящего из контейнеров busybox и multitool.
2. Создать PV и PVC для подключения папки на локальной ноде, которая будет использована в поде.
3. Продемонстрировать, что multitool может читать файл, в который busybox пишет каждые пять секунд в общей директории.
4. Удалить Deployment и PVC. Продемонстрировать, что после этого произошло с PV. Пояснить, почему.
5. Продемонстрировать, что файл сохранился на локальном диске ноды. Удалить PV.  Продемонстрировать что произошло с файлом после удаления PV. Пояснить, почему.
6. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

### Ответ

[PV Manifest](task1_pv.yml)

[Deployment + PVC](task1.yml)

1. Доступ к общему файлу изнутри Multitool:

```shell
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.7. Storage_p.2 on main]
$ kubectl exec -it filereader-665b5f5b56-xg4sr -c multitool -- tail -f /input/test.txt
17.07.2023 01:11:24: Hello, Netology!
17.07.2023 01:11:29: Hello, Netology!
17.07.2023 01:11:34: Hello, Netology!
17.07.2023 01:11:39: Hello, Netology!
17.07.2023 01:11:44: Hello, Netology!
17.07.2023 01:11:49: Hello, Netology!
17.07.2023 01:11:54: Hello, Netology!
17.07.2023 01:11:59: Hello, Netology!
17.07.2023 01:12:04: Hello, Netology!
17.07.2023 01:12:09: Hello, Netology!
17.07.2023 01:12:14: Hello, Netology!
```

2. Удаление деплоймента и pvc.

```shell
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.7. Storage_p.2 on main]
$ kubectl get pv local-pv                                                                       
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM     STORAGECLASS   REASON   AGE
local-pv   500Mi      RWO            Recycle          Bound    default/local-pvc                30s
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.7. Storage_p.2 on main]
$ kubectl delete deployments.apps/filereader                                          
deployment.apps "filereader" deleted
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.7. Storage_p.2 on main]
$ kubectl get pv local-pv                                                                       
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM    STORAGECLASS   REASON   AGE
local-pv   500Mi      RWO            Recycle          Bound    default/local-pvc                41s
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.7. Storage_p.2 on main]
$ kubectl delete pvc/local-pvc                                                                  
persistentvolumeclaim "local-pvc" deleted
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.7. Storage_p.2 on main]
$ kubectl get pv local-pv                                                                       
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS     CLAIM      STORAGECLASS   REASON   AGE
local-pv   500Mi      RWO            Recycle          Released   default    local-pvc               75s
```

После удаление деплоймента и pvc, pv вернулся обратно в пул со статусом Released, т.к. для него установлена политика Recycle.

3. Удаление PV.

```shell
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.7. Storage_p.2 on main]
$ kubectl delete pv/local-pv                                                              
persistentvolume "local-pv" deleted
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.7. Storage_p.2 on main]
$ cat /tmp/pvdemo/test.txt                        
cat: /tmp/pvdemo/test.txt: No such file or directory
```

Файл отсутствует, т.к. был удалён в момент удаления PVC (поскольку выбрана политика Recycle, pv был очищен). Если поставить Retain, файл сохранится.

### Задание 2

**Что нужно сделать**

Создать Deployment приложения, которое может хранить файлы на NFS с динамическим созданием PV.

1. Включить и настроить NFS-сервер на MicroK8S.
2. Создать Deployment приложения состоящего из multitool, и подключить к нему PV, созданный автоматически на сервере NFS.
3. Продемонстрировать возможность чтения и записи файла изнутри пода. 
4. Предоставить манифесты, а также скриншоты или вывод необходимых команд.

### Ответ

[Manifest](task2.yml)

```shell
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.7. Storage_p.2 on main]
$ kubectl apply -f task2.yml                                                           
deployment.apps/multitool unchanged
persistentvolumeclaim/nfs-pvc configured
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.7. Storage_p.2 on main]
$ kubectl get pvc/nfs-pvc                                                              
NAME      STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
nfs-pvc   Bound    pvc-40bf04e3-0ae9-4725-aa98-8cdd41ba824e   1Gi        RWO            nfs            75s
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.7. Storage_p.2 on main]
$ touch /var/snap/microk8s/common/nfs-storage/pvc-40bf04e3-0ae9-4725-aa98-8cdd41ba824e/test.txt                          ✭
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.7. Storage_p.2 on main]
$ kubectl exec -it multitool-b6848dcbf-9n4gr -- ls /data                               
test.txt
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.7. Storage_p.2 on main]
$ kubectl exec -it multitool-b6848dcbf-9n4gr -- touch /data/test2.txt                  
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.7. Storage_p.2 on main]
$ ls /var/snap/microk8s/common/nfs-storage/pvc-40bf04e3-0ae9-4725-aa98-8cdd41ba824e/   
test2.txt  test.txt
```