### NETWORKS ###

resource "yandex_vpc_network" "main" {
  name = "main"
}

resource "yandex_vpc_subnet" "public" {
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.main.id}"
  name = "public"
}

resource "yandex_vpc_subnet" "public2" {
  v4_cidr_blocks = ["192.168.11.0/24"]
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.main.id}"
  name = "public2"
}

resource "yandex_vpc_subnet" "public3" {
  v4_cidr_blocks = ["192.168.12.0/24"]
  zone           = "ru-central1-c"
  network_id     = "${yandex_vpc_network.main.id}"
  name = "public3"
}

resource "yandex_vpc_subnet" "private" {
  v4_cidr_blocks = ["192.168.20.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.main.id}"
  name = "private"
  # route_table_id = "${yandex_vpc_route_table.nat_route.id}"
}

resource "yandex_vpc_subnet" "private2" {
  v4_cidr_blocks = ["192.168.21.0/24"]
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.main.id}"
  name = "private2"
  # route_table_id = "${yandex_vpc_route_table.nat_route.id}"
}

resource "yandex_vpc_subnet" "private3" {
  v4_cidr_blocks = ["192.168.22.0/24"]
  zone           = "ru-central1-c"
  network_id     = "${yandex_vpc_network.main.id}"
  name = "private3"
  # route_table_id = "${yandex_vpc_route_table.nat_route.id}"
}

### ROUTING ###

# resource "yandex_vpc_route_table" "nat_route" {
#   network_id = "${yandex_vpc_network.main.id}"

#   static_route {
#     destination_prefix = "0.0.0.0/0"
#     next_hop_address = "${yandex_compute_instance.nat.network_interface[0].ip_address}"
#   }
# }

# resource "yandex_compute_instance" "nat" {
#   name        = "nat"
#   platform_id = "standard-v1"
#   zone        = "ru-central1-a"
#   allow_stopping_for_update = true

#   resources {
#     cores  = 2
#     memory = 2
#     core_fraction = 20
#   }

#   boot_disk {
#     initialize_params {
#       image_id = "fd8qmbqk94q6rhb4m94t"
#     }
#   }

#   network_interface {
#     subnet_id = "${yandex_vpc_subnet.public.id}"
#     ip_address = "192.168.10.254"
#     nat = true
#   }

#   scheduling_policy {
#     preemptible = true
#   }

#   metadata = {
#     ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
#   }
# }

