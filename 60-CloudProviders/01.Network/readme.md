# Домашнее задание к занятию «Организация сети»

---
### Задание 1. Yandex Cloud 

Манифесты находятся здесь:

[terraform](../terraform)

```shell
➜  terraform git:(main) ✗ terraform apply
...
yandex_vpc_network.main: Creating...
yandex_vpc_network.main: Creation complete after 1s [id=enpa401c77a1kjunsbp1]
yandex_vpc_subnet.public: Creating...
yandex_vpc_subnet.public: Creation complete after 1s [id=e9b5823dnqnbpdt132m4]
yandex_compute_instance.public_vm: Creating...
yandex_compute_instance.nat: Creating...
yandex_compute_instance.public_vm: Still creating... [10s elapsed]
yandex_compute_instance.nat: Still creating... [10s elapsed]
yandex_compute_instance.public_vm: Still creating... [20s elapsed]
yandex_compute_instance.nat: Still creating... [20s elapsed]
yandex_compute_instance.public_vm: Still creating... [30s elapsed]
yandex_compute_instance.nat: Still creating... [30s elapsed]
yandex_compute_instance.nat: Creation complete after 32s [id=fhmctets2hgemrpuqeg7]
yandex_vpc_route_table.nat_route: Creating...
yandex_vpc_route_table.nat_route: Creation complete after 2s [id=enpnelup8stradh3nump]
yandex_vpc_subnet.private: Creating...
yandex_compute_instance.public_vm: Creation complete after 34s [id=fhm1gt2fuemrn1k1unr4]
yandex_vpc_subnet.private: Creation complete after 1s [id=e9bfa6ncjbffa8rqbks2]
yandex_compute_instance.private_vm: Creating...
yandex_compute_instance.private_vm: Still creating... [10s elapsed]
yandex_compute_instance.private_vm: Still creating... [20s elapsed]
yandex_compute_instance.private_vm: Still creating... [30s elapsed]
yandex_compute_instance.private_vm: Creation complete after 30s [id=fhmb52jce0bbjg3doccq]

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

ip = "51.250.13.217"
ip_private = "192.168.20.19"
```

**Что нужно сделать**

1. Создать пустую VPC. Выбрать зону.

```hcl
resource "yandex_vpc_network" "main" {
  name = "main"
}
```

2. Публичная подсеть.

 - Создать в VPC subnet с названием public, сетью 192.168.10.0/24.

```hcl
resource "yandex_vpc_subnet" "public" {
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.main.id}"
  name = "public"
}
```

 - Создать в этой подсети NAT-инстанс, присвоив ему адрес 192.168.10.254. В качестве image_id использовать fd80mrhj8fl2oe87o4e1.

```hcl
resource "yandex_compute_instance" "nat" {
  name        = "nat"
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8qmbqk94q6rhb4m94t"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.public.id}"
    ip_address = "192.168.10.254"
    nat = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
```

 - Создать в этой публичной подсети виртуалку с публичным IP, подключиться к ней и убедиться, что есть доступ к интернету.

 ```hcl
 resource "yandex_compute_instance" "public_vm" {
  name        = "public-vm"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8n6sult0bipcm75u12"
    }
  }
  ```

  ```shell
  ➜  terraform git:(main) ✗ ssh ubuntu@51.250.13.217             
The authenticity of host '51.250.13.217 (51.250.13.217)' can't be established.
ED25519 key fingerprint is SHA256:5X2fntK+eQtPF0et9dzrumoZLDq2DHslhAIfcI/MSpA.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '51.250.13.217' (ED25519) to the list of known hosts.
Welcome to Ubuntu 22.04.3 LTS (GNU/Linux 5.15.0-78-generic x86_64)

...

ubuntu@fhm1gt2fuemrn1k1unr4:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=58 time=16.3 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=58 time=16.3 ms
^C
--- 8.8.8.8 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1002ms
rtt min/avg/max/mdev = 16.253/16.286/16.319/0.033 ms
ubuntu@fhm1gt2fuemrn1k1unr4:~$   
  ```

3. Приватная подсеть.

 - Создать в VPC subnet с названием private, сетью 192.168.20.0/24.

```hcl
resource "yandex_vpc_subnet" "private" {
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.main.id}"
  name = "private"
  route_table_id = "${yandex_vpc_route_table.nat_route.id}"
}
```

 - Создать route table. Добавить статический маршрут, направляющий весь исходящий трафик private сети в NAT-инстанс.

```hcl
resource "yandex_vpc_route_table" "nat_route" {
  network_id = "${yandex_vpc_network.main.id}"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = "${yandex_compute_instance.nat.network_interface[0].ip_address}"
  }
}
```

 - Создать в этой приватной подсети виртуалку с внутренним IP, подключиться к ней через виртуалку, созданную ранее, и убедиться, что есть доступ к интернету.

 ```hcl
 resource "yandex_compute_instance" "private_vm" {
  name        = "private-vm"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8n6sult0bipcm75u12"
    }
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.private.id}"
    nat = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
```

```shell
➜  terraform git:(main) ✗ scp ~/.ssh/id_rsa ubuntu@51.250.13.217:/home/ubuntu/.ssh/id_rsa
id_rsa      
100% 2610    23.9KB/s   00:00    
➜  terraform git:(main) ✗ ssh ubuntu@51.250.13.217
...
ubuntu@fhm1gt2fuemrn1k1unr4:~$ ssh 192.168.20.19
The authenticity of host '192.168.20.19 (192.168.20.19)' can't be established.
ED25519 key fingerprint is SHA256:a4SRJvx6cvbrkiQ6OYsF0uWeD9xwKI+N9i3NkC+eTic.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '192.168.20.19' (ED25519) to the list of known hosts.
...
ubuntu@fhmb52jce0bbjg3doccq:~$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=1 ttl=54 time=20.4 ms
64 bytes from 8.8.8.8: icmp_seq=2 ttl=54 time=19.5 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=54 time=19.4 ms
^C
--- 8.8.8.8 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 19.428/19.769/20.413/0.455 ms
ubuntu@fhmb52jce0bbjg3doccq:~$ 
```

Resource Terraform для Yandex Cloud:

- [VPC subnet](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_subnet).
- [Route table](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/vpc_route_table).
- [Compute Instance](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/compute_instance).

