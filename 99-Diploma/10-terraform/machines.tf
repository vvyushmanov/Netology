resource "yandex_compute_instance" "master" {

    name = "master"
    folder_id = local.folder_id
    zone = "ru-central1-a"

    resources {
        cores  = 2
        memory = 8
        core_fraction = 20
    }

    allow_stopping_for_update = true

    network_interface {
        subnet_id = yandex_vpc_subnet.public-a.id
        nat = true
    }

    scheduling_policy {
        preemptible = true
    }

    metadata = {
        ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }

    boot_disk {
        initialize_params {
        # Ubuntu 22.04 LTS
        image_id = "fd8tkfhqgbht3sigr37c"
        size = 20
        }
    }
}

resource "yandex_compute_instance" "worker1" {

    name = "worker1"
    folder_id = local.folder_id
    zone = "ru-central1-b"

    resources {
        cores  = 2
        memory = 8
        core_fraction = 20
    }

    allow_stopping_for_update = true

    network_interface {
        subnet_id = yandex_vpc_subnet.public-b.id
        nat = true
    }

    scheduling_policy {
        preemptible = true
    }

    metadata = {
        ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }

    boot_disk {
        initialize_params {
        # Ubuntu 22.04 LTS
        image_id = "fd8tkfhqgbht3sigr37c"
        size = 20
        }
    }
}

resource "yandex_compute_instance" "worker2" {

    name = "worker2"
    folder_id = local.folder_id
    zone = "ru-central1-c"

    resources {
        cores  = 2
        memory = 8 
        core_fraction = 20
    }

    allow_stopping_for_update = true

    network_interface {
        subnet_id = yandex_vpc_subnet.public-c.id
        nat = true
    }

    scheduling_policy {
        preemptible = true
    }

    metadata = {
        ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }

    boot_disk {
        initialize_params {
        # Ubuntu 22.04 LTS
        image_id = "fd8tkfhqgbht3sigr37c"
        size = 20
        }
    }
}