# Домашнее задание к занятию «Управление доступом»

### Цель задания

В тестовой среде Kubernetes нужно предоставить ограниченный доступ пользователю.

------

### Задание 1. Создайте конфигурацию для подключения пользователя

1. Создайте и подпишите SSL-сертификат для подключения к кластеру.

```shell
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.9. RBAC/cert on main]
$ openssl genrsa -out user.key 2048        
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.9. RBAC/cert on main]
$ openssl req -new -key user.key -out user.csr -subj “/CN=user1/O=group1”
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.9. RBAC/cert on main]
$ openssl x509 -req -in user.csr -CA /var/snap/microk8s/current/certs/ca.crt -CAkey /var/snap/microk8s/current/certs/ca.key -CAcreateserial -out user.crt -days 500
Certificate request self-signature ok
subject=CN = user, O = group1
```

2. Настройте конфигурационный файл kubectl для подключения.

```shell
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.9. RBAC/cert on main]
$ kubectl config set-credentials user --client-certificate=user.crt --client-key user.key       
User "user" set.
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.9. RBAC/cert on main]
$ kubectl config set-context user-context --cluster=microk8s-cluster --user=user     
Context "user-context" created.
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.9. RBAC on main]
$ kubectl config view                                            
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://192.168.50.218:16443
  name: microk8s-cluster
contexts:
- context:
    cluster: microk8s-cluster
    user: admin
  name: microk8s
- context:
    cluster: microk8s-cluster
    namespace: rbac
    user: user
  name: user-context
current-context: user-context
kind: Config
preferences: {}
users:
- name: admin
  user:
    token: REDACTED
- name: user
  user:
    client-certificate: /home/vyushmanov/Repos/devops-netology/5_K8S/5.9. RBAC/cert/user.crt
    client-key: /home/vyushmanov/Repos/devops-netology/5_K8S/5.9. RBAC/cert/user.key
```

3. Создайте роли и все необходимые настройки для пользователя.


[Role](role.yaml)

[RoleBinding](rolebinding.yaml)

4. Предусмотрите права пользователя. Пользователь может просматривать логи подов и их конфигурацию (`kubectl logs pod <pod_id>`, `kubectl describe pod <pod_id>`).
5. Предоставьте манифесты и скриншоты и/или вывод необходимых команд.

```shell
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.9. RBAC/cert on main]
$ kubectl config use-context user-context  
Switched to context "user-context".
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.9. RBAC on main]
$ kubectl logs pods/test-app                                                        
/docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
/docker-entrypoint.sh: Looking for shell scripts in /docker-entrypoint.d/
/docker-entrypoint.sh: Launching /docker-entrypoint.d/10-listen-on-ipv6-by-default.sh
10-listen-on-ipv6-by-default.sh: info: Getting the checksum of /etc/nginx/conf.d/default.conf
......
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.9. RBAC on main]
$ kubectl describe pods/test-app                                                                             130 ↵ ✭
Name:             test-app
Namespace:        rbac
Priority:         0
Service Account:  default
Node:             vyushmanov-gl703vd/192.168.50.218
Start Time:       Sat, 22 Jul 2023 04:31:21 +0400
Labels:           name=test-app
Annotations:      cni.projectcalico.org/containerID: 90e5c38b715ed7b680eb3d3c87b8524037e714f471ac114888cf57d781d278ea
                  cni.projectcalico.org/podIP: 10.1.125.209/32
                  cni.projectcalico.org/podIPs: 10.1.125.209/32
Status:           Running
IP:               10.1.125.209
IPs:
  IP:  10.1.125.209
Containers:
  test-app:
    Container ID:   containerd://185358bf375f46f92b13996978e54873b0560ff12d43540f22aefa238bc18385
    Image:          nginx
    Image ID:       docker.io/library/nginx@sha256:08bc36ad52474e528cc1ea3426b5e3f4bad8a130318e3140d6cfe29c8892c7ef
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Sat, 22 Jul 2023 04:31:24 +0400
    Ready:          True
    Restart Count:  0
    Limits:
      cpu:     500m
      memory:  128Mi
    Requests:
      cpu:        500m
      memory:     128Mi
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-l28kk (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-l28kk:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   Guaranteed
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:                      <none>

```
