# Домашнее задание к занятию «Базовые объекты K8S»



### Задание 1. Создать Pod с именем hello-world

1. Создать манифест (yaml-конфигурацию) Pod.
2. Использовать image - gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
3. Подключиться локально к Pod с помощью `kubectl port-forward` и вывести значение (curl или в браузере).

### Ответ

[Манифест](demo_pod.yaml)

```shell
$ kubectl apply -f demo_pod.yaml                               
pod/hello-world created

$ kubectl port-forward pods/hello-world 30080:8080                                                                                           
Forwarding from 127.0.0.1:30080 -> 8080
Forwarding from [::1]:30080 -> 8080
Handling connection for 30080
```

``` shell
[vyushmanov@vyushmanov-GL703VD:~]
$ curl localhost:30080                                                     


Hostname: hello-world

Pod Information:
	-no pod information available-

Server values:
	server_version=nginx: 1.12.2 - lua: 10010

Request Information:
	client_address=127.0.0.1
	method=GET
	real path=/
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://localhost:8080/

Request Headers:
	accept=*/*  
	host=localhost:30080  
	user-agent=curl/7.81.0  

Request Body:
	-no body in request-
```

```shell
[vyushmanov@vyushmanov-GL703VD:~/Repos/devops-netology/5_K8S/5.2. Basic objects on main]
$ kubectl get pods                                                                                  
NAME          READY   STATUS    RESTARTS   AGE
hello-world   1/1     Running   0          6m7s
```

------

### Задание 2. Создать Service и подключить его к Pod

1. Создать Pod с именем netology-web.
2. Использовать image — gcr.io/kubernetes-e2e-test-images/echoserver:2.2.
3. Создать Service с именем netology-svc и подключить к netology-web.
4. Подключиться локально к Service с помощью `kubectl port-forward` и вывести значение (curl или в браузере).

[Манифест](netology-web.yaml)

```shell
$ kubectl apply -f netology-web.yaml                         
pod/netology-web created
service/netology-svc created

$ kubectl port-forward svc/netology-svc 9080:9080  
Forwarding from 127.0.0.1:9080 -> 8080
Forwarding from [::1]:9080 -> 8080
Handling connection for 9080

```

```shell
$ curl localhost:9080


Hostname: netology-web

Pod Information:
	-no pod information available-

Server values:
	server_version=nginx: 1.12.2 - lua: 10010

Request Information:
	client_address=127.0.0.1
	method=GET
	real path=/
	query=
	request_version=1.1
	request_scheme=http
	request_uri=http://localhost:8080/

Request Headers:
	accept=*/*  
	host=localhost:9080  
	user-agent=curl/7.81.0  

Request Body:
	-no body in request-

```

```shell
$ kubectl get pods                                                                                          
NAME           READY   STATUS    RESTARTS   AGE
netology-web   1/1     Running   0          7m19s
hello-world    1/1     Running   0          4m43s
```

```shell
$ kubectl describe svc netology-web                                                                                
Name:              netology-web
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=web
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.152.183.254
IPs:               10.152.183.254
Port:              <unset>  9080/TCP
TargetPort:        8080/TCP
Endpoints:         10.1.125.255:8080
Session Affinity:  None
Events:            <none>

$ kubectl exec -it hello-world -- /bin/sh 

/ # ping 10.1.125.255
PING 10.1.125.255 (10.1.125.255): 56 data bytes
64 bytes from 10.1.125.255: seq=0 ttl=63 time=0.287 ms
64 bytes from 10.1.125.255: seq=1 ttl=63 time=0.175 ms
64 bytes from 10.1.125.255: seq=2 ttl=63 time=0.175 ms
```
