resource "yandex_iam_service_account" "k8s-sa" {
 name        = "k8s-sa"
 description = "Service account for Kubernetes cluster"
}

resource "yandex_resourcemanager_folder_iam_member" "editor" {
 folder_id = local.folder_id
 role      = "editor"
 member    = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "images-puller" {
 folder_id = local.folder_id
 role      = "container-registry.images.puller"
 member    = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
}

resource "yandex_resourcemanager_folder_iam_member" "public-admin" {
 folder_id = local.folder_id
 role      = "vpc.publicAdmin"
 member    = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
}

resource "yandex_kubernetes_cluster" "k8s-regional" {

  name = "test-k8s-cluster"

  network_id = yandex_vpc_network.main.id
  

  master {
    version = 1.25
    public_ip = true
    regional {
      region = "ru-central1"
      location {
        zone      = yandex_vpc_subnet.public.zone
        subnet_id = yandex_vpc_subnet.public.id
      }
      location {
        zone      = yandex_vpc_subnet.public2.zone
        subnet_id = yandex_vpc_subnet.public2.id
      }
      location {
        zone      = yandex_vpc_subnet.public3.zone
        subnet_id = yandex_vpc_subnet.public3.id
      }
    }
  }

  service_account_id      = yandex_iam_service_account.k8s-sa.id
  node_service_account_id = yandex_iam_service_account.k8s-sa.id

  depends_on = [
    yandex_resourcemanager_folder_iam_member.editor,
    yandex_resourcemanager_folder_iam_member.images-puller,
    yandex_resourcemanager_folder_iam_member.public-admin
  ]
  kms_provider {
    key_id = yandex_kms_symmetric_key.key-a.id
  }
}

resource "yandex_kubernetes_node_group" "my_node_group" {
  cluster_id  = yandex_kubernetes_cluster.k8s-regional.id
  name        = "k8s-group"
  description = "description"
  version     = "1.25"

  instance_template {
    platform_id = "standard-v1"

    network_interface {
      nat                = true
      subnet_ids         = [
        "${yandex_vpc_subnet.public.id}"
      ]
    }

    resources {
      memory = 2
      cores  = 2
      core_fraction = 5
    }

    boot_disk {
      type = "network-hdd"
      size = 30
    }

    scheduling_policy {
      preemptible = true
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    auto_scale {
      min = 3
      initial = 3
      max = 6
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-a"
    }

  }  
}