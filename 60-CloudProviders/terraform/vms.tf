# resource "yandex_compute_instance" "public_vm" {
#   name        = "public-vm"
#   platform_id = "standard-v1"
#   zone        = "ru-central1-a"
#   allow_stopping_for_update = true

#   resources {
#     cores  = 2
#     memory = 2
#     core_fraction = 5
#   }

#   boot_disk {
#     initialize_params {
#       image_id = "fd8n6sult0bipcm75u12"
#     }
#   }

#   network_interface {
#     subnet_id = "${yandex_vpc_subnet.public.id}"
#     nat = true
#   }

#   scheduling_policy {
#     preemptible = true
#   }

#   metadata = {
#     ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
#     user-data = "${templatefile(
#         "http-server-bootstrap.sh.tftpl", 
#         { 
#           bucket = "${yandex_storage_object.two-b.bucket}", 
#           file = "${yandex_storage_object.two-b.key}" 
#         }
#       )
#     }"
#   }

# }

# output "ip" {
#   value = "${yandex_compute_instance.public_vm.network_interface[0].nat_ip_address}"
# }

# resource "yandex_compute_instance" "private_vm" {
#   name        = "private-vm"
#   platform_id = "standard-v1"
#   zone        = "ru-central1-a"
#   allow_stopping_for_update = true

#   resources {
#     cores  = 2
#     memory = 2
#     core_fraction = 5
#   }

#   boot_disk {
#     initialize_params {
#       image_id = "fd8n6sult0bipcm75u12"
#     }
#   }

#   network_interface {
#     subnet_id = "${yandex_vpc_subnet.private.id}"
#     nat = false
#   }

#   metadata = {
#     ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
#   }

#   scheduling_policy {
#     preemptible = true
#   }
# }

# output "ip_private" {
#   value = "${yandex_compute_instance.private_vm.network_interface[0].ip_address}"
# }

resource "yandex_iam_service_account" "ig-sa" {
  name        = "ig-sa"
  description = "service account to manage IG"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
  folder_id = "b1gen0ivt5de5o1t09r6"
  role      = "editor"
  member   = "serviceAccount:${yandex_iam_service_account.ig-sa.id}"
}

resource "yandex_compute_instance_group" "balanced-vms" {
  name = "balanced-group"
  folder_id = "b1gen0ivt5de5o1t09r6"
  service_account_id  = "${yandex_iam_service_account.ig-sa.id}"
  

  instance_template {

    resources {
      cores  = 2
      memory = 2
      core_fraction = 5
    }

    network_interface {
      network_id = "${yandex_vpc_network.main.id}"
      subnet_ids = ["${yandex_vpc_subnet.public.id}"]
    }

    scheduling_policy {
      preemptible = true
    }

    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
      user-data = "${templatefile(
          "http-server-bootstrap.sh.tftpl", 
          { 
            bucket = "${yandex_storage_object.two-b.bucket}", 
            file = "${yandex_storage_object.two-b.key}" 
          }
        )
      }"
    }

    boot_disk {
      initialize_params {
        image_id = "fd88asm0l117f4gl6nkl"
      }
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  health_check {
    http_options {
      port = 80
      path = "/"
    }
    timeout = 10
    unhealthy_threshold = 2
    interval = 30

  }

  # load_balancer {
  #   target_group_name = "balanced-vms"
  # }  

  application_load_balancer {
    target_group_name = "l7-balancer"
  }
}

resource "yandex_compute_instance_group" "net-balanced-vms" {
  name = "net-balanced-group"
  folder_id = "b1gen0ivt5de5o1t09r6"
  service_account_id  = "${yandex_iam_service_account.ig-sa.id}"
  

  instance_template {

    resources {
      cores  = 2
      memory = 2
      core_fraction = 5
    }

    network_interface {
      network_id = yandex_vpc_network.main.id
      subnet_ids = ["${yandex_vpc_subnet.public.id}"]
    }

    scheduling_policy {
      preemptible = true
    }

    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
      user-data = "${templatefile(
          "http-server-bootstrap.sh.tftpl", 
          { 
            bucket = "${yandex_storage_object.two-b.bucket}", 
            file = "${yandex_storage_object.two-b.key}" 
          }
        )
      }"
    }

    boot_disk {
      initialize_params {
        image_id = "fd88asm0l117f4gl6nkl"
      }
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }

  allocation_policy {
    zones = ["ru-central1-a"]
  }

  health_check {
    http_options {
      port = 80
      path = "/"
    }
    timeout = 10
    unhealthy_threshold = 2
    interval = 30

  }

  load_balancer {
    target_group_name = "net-balanced-vms"
  }  
}