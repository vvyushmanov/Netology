# resource "yandex_compute_instance" "master" {

#     name = "master"
#     folder_id = local.folder_id
#     zone = "ru-central1-a"

#     resources {
#         cores  = 2
#         memory = 8
#         core_fraction = 20
#     }

#     allow_stopping_for_update = true

#     network_interface {
#         subnet_id = yandex_vpc_subnet.public-a.id
#         nat = true
#     }

#     scheduling_policy {
#         preemptible = true
#     }

#     metadata = {
#         ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
#     }

#     boot_disk {
#         initialize_params {
#         # Ubuntu 22.04 LTS
#         image_id = "fd8tkfhqgbht3sigr37c"
#         size = 20
#         }
#     }
# }

# resource "yandex_compute_instance" "worker1" {

#     name = "worker1"
#     folder_id = local.folder_id
#     zone = "ru-central1-b"

#     resources {
#         cores  = 2
#         memory = 8
#         core_fraction = 20
#     }

#     allow_stopping_for_update = true

#     network_interface {
#         subnet_id = yandex_vpc_subnet.public-b.id
#         nat = true
#     }

#     scheduling_policy {
#         preemptible = true
#     }

#     metadata = {
#         ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
#     }

#     boot_disk {
#         initialize_params {
#         # Ubuntu 22.04 LTS
#         image_id = "fd8tkfhqgbht3sigr37c"
#         size = 20
#         }
#     }
# }

# resource "yandex_compute_instance" "worker2" {

#     name = "worker2"
#     folder_id = local.folder_id
#     zone = "ru-central1-c"

#     resources {
#         cores  = 2
#         memory = 8 
#         core_fraction = 20
#     }

#     allow_stopping_for_update = true

#     network_interface {
#         subnet_id = yandex_vpc_subnet.public-c.id
#         nat = true
#     }

#     scheduling_policy {
#         preemptible = true
#     }

#     metadata = {
#         ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
#     }

#     boot_disk {
#         initialize_params {
#         # Ubuntu 22.04 LTS
#         image_id = "fd8tkfhqgbht3sigr37c"
#         size = 20
#         }
#     }
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

resource "yandex_compute_instance_group" "k8s-ig" {
  name                = "k8s-ig"
  folder_id           = local.folder_id
  service_account_id  = "${yandex_iam_service_account.ig-sa.id}"

  instance_template {

    resources {
      memory = 8
      cores  = 2
      core_fraction = 20
    }

    scheduling_policy {
      preemptible = true
    }

    boot_disk {
        initialize_params {
        # Ubuntu 22.04 LTS
        image_id = "fd8tkfhqgbht3sigr37c"
        size = 20
        }
    }

    network_interface {
      network_id = yandex_vpc_network.main.id
      nat = true
      subnet_ids = [ 
        yandex_vpc_subnet.public-a.id, 
        yandex_vpc_subnet.public-b.id, 
        yandex_vpc_subnet.public-c.id  
        ]

      
    }    


    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }

    network_settings {
      type = "STANDARD"
    }
  }

  scale_policy {
    auto_scale {
      initial_size = 3
      measurement_duration = 300
      custom_rule {
        rule_type = "UTILIZATION"
        metric_name = "utilization"
        metric_type = "COUNTER"
        target = 80
      }
      min_zone_size = 1
      max_size = 6
      warmup_duration = 120
      stabilization_duration = 120
    }
  }

  application_load_balancer {
    target_group_name = "k8s-l7-lb-group"
  }

  allocation_policy {
    zones = ["ru-central1-a", "ru-central1-b", "ru-central1-c"]
  }

  deploy_policy {
    max_unavailable = 2
    max_creating    = 3
    max_expansion   = 2
    max_deleting    = 2
  }
}