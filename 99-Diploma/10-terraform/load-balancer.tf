### K8S APISERVER ###

resource "yandex_lb_target_group" "control-planes" {
    name = "control-planes"
    region_id = "ru-central1"

    target {
      subnet_id = yandex_vpc_subnet.public-a.id
      address = yandex_compute_instance.master.network_interface[0].ip_address
    }

    target {
      subnet_id = yandex_vpc_subnet.public-b.id
      address = yandex_compute_instance.worker1.network_interface[0].ip_address
    }
}

resource "yandex_lb_network_load_balancer" "k8s-cplane" {

    name = "k8s-cplane"

    listener {
      name = "k8s-apiserver"
      port = 6443
      external_address_spec {
        ip_version = "ipv4" 
      }
    }

    attached_target_group {
      target_group_id = yandex_lb_target_group.control-planes.id
      healthcheck {
        name = "healthcheck"
        tcp_options {
          port = 6443
        }
      }
    }
  
}

### HTTP L7 LB ###

resource "yandex_alb_target_group" "http-nodes" {
  name = "http-nodes"
  
  target {
      subnet_id = yandex_vpc_subnet.public-a.id
      ip_address = yandex_compute_instance.master.network_interface[0].ip_address
    }

    target {
      subnet_id = yandex_vpc_subnet.public-b.id
      ip_address = yandex_compute_instance.worker1.network_interface[0].ip_address
    }

    target {
      subnet_id = yandex_vpc_subnet.public-c.id
      ip_address = yandex_compute_instance.worker2.network_interface[0].ip_address
    }
  
}

resource "yandex_alb_backend_group" "http-lb" {
  name = "http-lb-bg"

  http_backend {
    name = "http-back"
    port = 80
    weight = 1 
    target_group_ids = [ "${yandex_alb_target_group.http-nodes.id}" ]
  
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
        backend_group_id = yandex_alb_backend_group.http-lb.id
        timeout          = "60s"
      }
    }
  }
} 

resource "yandex_alb_load_balancer" "k8s-l7-balancer" {

  name = "k8s-l7-balancer"
  network_id = yandex_vpc_network.main.id

  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public-a.id
    }

    location {
      zone_id   = "ru-central1-b"
      subnet_id = yandex_vpc_subnet.public-b.id
    }

    location {
      zone_id   = "ru-central1-c"
      subnet_id = yandex_vpc_subnet.public-c.id
    }
  }

  listener {
    name = "l7-balancer-listener"
    endpoint {
      address {
        external_ipv4_address {          
        }
      }
      ports = [ 80 ]
    }
    http {
      handler {
        http_router_id = yandex_alb_http_router.tf-router.id
      }
    }
  }
  
}



