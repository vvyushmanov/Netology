# Домашнее задание к занятию «Обновление приложений»

### Цель задания

Выбрать и настроить стратегию обновления приложения.

-----

### Задание 1. Выбрать стратегию обновления приложения и описать ваш выбор

1. Имеется приложение, состоящее из нескольких реплик, которое требуется обновить.
2. Ресурсы, выделенные для приложения, ограничены, и нет возможности их увеличить.
3. Запас по ресурсам в менее загруженный момент времени составляет 20%.
4. Обновление мажорное, новые версии приложения не умеют работать со старыми.
5. Вам нужно объяснить свой выбор стратегии обновления приложения.

### Ответ 

Для обновления приложения с ограниченными ресурсами и мажорным обновлением, наиболее подходящей стратегией является Recreate. Причины следующие:

1. Новая версия несовместима со старой, следовательно нет ни смысла, ни возможности иметь параллельно как старую, так и новую версию.
2. Нет запаса по ресурсам, следовательно нет возможности создать A/B тестирование - не хватит мощностей для развёртываения такого же кластера.

При выборе recreate все реплики будут отключены одновременно (требований по времени простоя нет, потому можно сделать это без нарушения SLA), и на их месте подняты новые, с новой версией, одновременно.

### Задание 2. Обновить приложение

1. Создать deployment приложения с контейнерами nginx и multitool. Версию nginx взять 1.19. Количество реплик — 5.
2. Обновить версию nginx в приложении до версии 1.20, сократив время обновления до минимума. Приложение должно быть доступно.
3. Попытаться обновить nginx до версии 1.28, приложение должно оставаться доступным.
4. Откатиться после неудачного обновления.

### Ответ

[Манифест](10-depl-nginx-mtl.yaml)

1. Обновить до 1.20

Выставляем РоллингАпдейт с параметрами так, чтобы сократить до минимума скорость обновления, принебрегая ресурсами:

```yaml
 strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 5 
      maxUnavailable: 1 
```

```shell
➜  04.Update git:(main) ✗ kubectl apply -f .
deployment.apps/nginx configured
service/nginx unchanged
```

```shell
➜  04.Update git:(main) ✗ kubectl get pods -w
NAME                     READY   STATUS    RESTARTS   AGE
nginx-654ffc8bb5-44f48   2/2     Running   0          10m
nginx-654ffc8bb5-j7lsj   2/2     Running   0          10m
nginx-654ffc8bb5-gnrfc   2/2     Running   0          10m
nginx-654ffc8bb5-p8qfc   2/2     Running   0          10m
nginx-654ffc8bb5-v6bnw   2/2     Running   0          10m
nginx-7848b978f7-xtvlh   0/2     Pending   0          0s
nginx-654ffc8bb5-gnrfc   2/2     Terminating   0          10m
nginx-7848b978f7-tc5nq   0/2     Pending       0          0s
nginx-7848b978f7-rlzqc   0/2     Pending       0          0s
nginx-7848b978f7-tc5nq   0/2     Pending       0          0s
nginx-7848b978f7-xtvlh   0/2     Pending       0          0s
nginx-7848b978f7-lmr8m   0/2     Pending       0          0s
nginx-7848b978f7-t6bmx   0/2     Pending       0          0s
nginx-7848b978f7-rlzqc   0/2     Pending       0          0s
nginx-7848b978f7-tc5nq   0/2     ContainerCreating   0          0s
nginx-7848b978f7-lmr8m   0/2     Pending             0          1s
nginx-7848b978f7-xtvlh   0/2     ContainerCreating   0          1s
nginx-7848b978f7-t6bmx   0/2     Pending             0          1s
nginx-654ffc8bb5-gnrfc   2/2     Terminating         0          10m
nginx-654ffc8bb5-gnrfc   0/2     Terminating         0          10m
nginx-7848b978f7-tc5nq   0/2     ContainerCreating   0          1s
nginx-7848b978f7-xtvlh   0/2     ContainerCreating   0          1s
nginx-7848b978f7-rlzqc   0/2     Pending             0          2s
nginx-654ffc8bb5-gnrfc   0/2     Terminating         0          10m
nginx-7848b978f7-rlzqc   0/2     ContainerCreating   0          2s
nginx-654ffc8bb5-gnrfc   0/2     Terminating         0          10m
nginx-654ffc8bb5-gnrfc   0/2     Terminating         0          10m
nginx-7848b978f7-rlzqc   0/2     ContainerCreating   0          2s
nginx-7848b978f7-xtvlh   2/2     Running             0          4s
nginx-654ffc8bb5-j7lsj   2/2     Terminating         0          10m
nginx-654ffc8bb5-j7lsj   2/2     Terminating         0          10m
nginx-654ffc8bb5-j7lsj   0/2     Terminating         0          10m
nginx-7848b978f7-lmr8m   0/2     Pending             0          4s
nginx-7848b978f7-lmr8m   0/2     ContainerCreating   0          4s
nginx-7848b978f7-tc5nq   2/2     Running             0          5s
nginx-654ffc8bb5-j7lsj   0/2     Terminating         0          10m
nginx-654ffc8bb5-j7lsj   0/2     Terminating         0          10m
nginx-654ffc8bb5-v6bnw   2/2     Terminating         0          10m
nginx-654ffc8bb5-j7lsj   0/2     Terminating         0          10m
nginx-7848b978f7-lmr8m   0/2     ContainerCreating   0          5s
nginx-654ffc8bb5-v6bnw   2/2     Terminating         0          10m
nginx-654ffc8bb5-v6bnw   0/2     Terminating         0          10m
nginx-654ffc8bb5-v6bnw   0/2     Terminating         0          10m
nginx-654ffc8bb5-v6bnw   0/2     Terminating         0          10m
nginx-654ffc8bb5-v6bnw   0/2     Terminating         0          10m
nginx-7848b978f7-rlzqc   2/2     Running             0          7s
nginx-654ffc8bb5-44f48   2/2     Terminating         0          10m
nginx-654ffc8bb5-44f48   2/2     Terminating         0          10m
nginx-654ffc8bb5-44f48   0/2     Terminating         0          10m
nginx-654ffc8bb5-44f48   0/2     Terminating         0          10m
nginx-654ffc8bb5-44f48   0/2     Terminating         0          10m
nginx-654ffc8bb5-44f48   0/2     Terminating         0          10m
nginx-7848b978f7-lmr8m   2/2     Running             0          8s
nginx-654ffc8bb5-p8qfc   2/2     Terminating         0          10m
nginx-654ffc8bb5-p8qfc   2/2     Terminating         0          10m
nginx-654ffc8bb5-p8qfc   0/2     Terminating         0          10m
nginx-7848b978f7-t6bmx   0/2     Pending             0          9s
nginx-7848b978f7-t6bmx   0/2     ContainerCreating   0          9s
nginx-654ffc8bb5-p8qfc   0/2     Terminating         0          10m
nginx-654ffc8bb5-p8qfc   0/2     Terminating         0          10m
nginx-654ffc8bb5-p8qfc   0/2     Terminating         0          10m
nginx-7848b978f7-t6bmx   0/2     ContainerCreating   0          9s
nginx-7848b978f7-t6bmx   2/2     Running             0          12s
```

2. Пытаемся обновить до 1.28 и откатить при неудаче:

```shell
➜  04.Update git:(main) ✗ kubectl apply -f .
deployment.apps/nginx configured
service/nginx unchanged
```

```shell
➜  04.Update git:(main) ✗ kubectl get pods -w
NAME                     READY   STATUS    RESTARTS   AGE
nginx-7848b978f7-xtvlh   2/2     Running   0          72s
nginx-7848b978f7-tc5nq   2/2     Running   0          72s
nginx-7848b978f7-rlzqc   2/2     Running   0          72s
nginx-7848b978f7-lmr8m   2/2     Running   0          72s
nginx-7848b978f7-t6bmx   2/2     Running   0          72s
nginx-5c87b5cbcc-mjzgh   0/2     Pending   0          0s
nginx-5c87b5cbcc-222j2   0/2     Pending   0          0s
nginx-5c87b5cbcc-mjzgh   0/2     Pending   0          0s
nginx-7848b978f7-lmr8m   2/2     Terminating   0          101s
nginx-5c87b5cbcc-222j2   0/2     Pending       0          0s
nginx-5c87b5cbcc-mjzgh   0/2     ContainerCreating   0          0s
nginx-5c87b5cbcc-whfp8   0/2     Pending             0          0s
nginx-5c87b5cbcc-222j2   0/2     ContainerCreating   0          0s
nginx-5c87b5cbcc-hzpd2   0/2     Pending             0          0s
nginx-5c87b5cbcc-22989   0/2     Pending             0          0s
nginx-5c87b5cbcc-whfp8   0/2     Pending             0          0s
nginx-5c87b5cbcc-hzpd2   0/2     Pending             0          1s
nginx-5c87b5cbcc-22989   0/2     Pending             0          1s
nginx-7848b978f7-lmr8m   2/2     Terminating         0          102s
nginx-7848b978f7-lmr8m   0/2     Terminating         0          102s
nginx-5c87b5cbcc-222j2   0/2     ContainerCreating   0          1s
nginx-5c87b5cbcc-mjzgh   0/2     ContainerCreating   0          1s
nginx-7848b978f7-lmr8m   0/2     Terminating         0          102s
nginx-7848b978f7-lmr8m   0/2     Terminating         0          102s
nginx-7848b978f7-lmr8m   0/2     Terminating         0          102s
nginx-5c87b5cbcc-whfp8   0/2     Pending             0          2s
nginx-5c87b5cbcc-whfp8   0/2     ContainerCreating   0          2s
nginx-5c87b5cbcc-whfp8   0/2     ContainerCreating   0          3s
nginx-5c87b5cbcc-222j2   1/2     ErrImagePull        0          16s
nginx-5c87b5cbcc-222j2   1/2     ImagePullBackOff    0          17s
nginx-5c87b5cbcc-mjzgh   1/2     ErrImagePull        0          17s
nginx-5c87b5cbcc-whfp8   1/2     ErrImagePull        0          18s
nginx-5c87b5cbcc-mjzgh   1/2     ImagePullBackOff    0          18s
nginx-5c87b5cbcc-whfp8   1/2     ImagePullBackOff    0          19s
```

```shell
➜  04.Update git:(main) ✗ kubectl get pods   
NAME                     READY   STATUS         RESTARTS   AGE
nginx-7848b978f7-xtvlh   2/2     Running        0          2m35s
nginx-7848b978f7-tc5nq   2/2     Running        0          2m35s
nginx-7848b978f7-rlzqc   2/2     Running        0          2m35s
nginx-7848b978f7-t6bmx   2/2     Running        0          2m35s
nginx-5c87b5cbcc-hzpd2   0/2     Pending        0          54s
nginx-5c87b5cbcc-22989   0/2     Pending        0          54s
nginx-5c87b5cbcc-222j2   1/2     ErrImagePull   0          54s
nginx-5c87b5cbcc-mjzgh   1/2     ErrImagePull   0          54s
nginx-5c87b5cbcc-whfp8   1/2     ErrImagePull   0          54s
```

```shell
➜  04.Update git:(main) ✗ kubectl rollout undo deployment/nginx 
deployment.apps/nginx rolled back
```

```shell
➜  04.Update git:(main) ✗ kubectl get pods   
NAME                     READY   STATUS    RESTARTS   AGE
nginx-7848b978f7-xtvlh   2/2     Running   0          4m46s
nginx-7848b978f7-tc5nq   2/2     Running   0          4m46s
nginx-7848b978f7-rlzqc   2/2     Running   0          4m46s
nginx-7848b978f7-t6bmx   2/2     Running   0          4m46s
nginx-7848b978f7-578t6   2/2     Running   0          33s
```