resource "yandex_vpc_network" "main" {
  name = "main"
}

resource "yandex_vpc_subnet" "public" {
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.main.id}"
  name = "public"
}

resource "yandex_vpc_subnet" "private" {
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.main.id}"
  name = "private"
  route_table_id = "${yandex_vpc_route_table.nat_route.id}"
}

resource "yandex_vpc_route_table" "nat_route" {
  network_id = "${yandex_vpc_network.main.id}"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address = "${yandex_compute_instance.nat.network_interface[0].ip_address}"
  }
}

resource "yandex_compute_instance" "nat" {
  name        = "nat"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
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

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}

resource "yandex_lb_network_load_balancer" "lb-1" {
  name = "network-load-balancer-1"

  listener {
    name = "network-load-balancer-1-listener"
    port = 80
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.net-balanced-vms.load_balancer.0.target_group_id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/index.html"
      }
    }
  }
}

resource "yandex_alb_backend_group" "l7-backend-group" {
  name = "my-backend"

  http_backend {
    name = "http-back"
    port = 80
    weight = 1 
    target_group_ids = [ "${yandex_compute_instance_group.balanced-vms.application_load_balancer.0.target_group_id}" ]
  
    load_balancing_config {
      panic_threshold = 50
    }    
    healthcheck {
      timeout = "1s"
      interval = "1s"
      http_healthcheck {
        path  = "/"
      }
    }
    http2 = "false"  
  }
}

resource "yandex_alb_http_router" "tf-router" {
  name   = "http-router"
}

resource "yandex_alb_virtual_host" "my-virtual-host" {
  name           = "virtual-host"
  http_router_id = yandex_alb_http_router.tf-router.id
  route {
    name = "default"
    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.l7-backend-group.id
        timeout          = "60s"
      }
    }
  }
} 

resource "yandex_alb_load_balancer" "l7-balancer" {

  name = "l7-balancer"
  network_id = yandex_vpc_network.main.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public.id
    }
  }

  listener {
    name = "l7-balancer-listener"
    endpoint {
      address {
        external_ipv4_address {          
        }
      }
      ports = [ 80, 443 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.tf-router.id
      }
    }
  }
  
}

# output "balancer-ip" {
#   value = yandex_lb_network_load_balancer.lb-1.listener.*.external_address_spec[0].*.listener[0].external_address_spec.address
# }


# output "l7-balancer-ip" {
#   value = yandex_alb_load_balancer.l7-balancer.listener.*.endpoint[0].*.address[0].*.external_ipv4_address[0].address
# }