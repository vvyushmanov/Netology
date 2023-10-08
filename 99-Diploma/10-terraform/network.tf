resource "yandex_vpc_network" "main" {
  name = "main"
}

resource "yandex_vpc_subnet" "public-a" {
  v4_cidr_blocks = ["192.168.10.0/24"]
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.main.id}"
  name = "public-a"
}

resource "yandex_vpc_subnet" "public-b" {
  v4_cidr_blocks = ["192.168.11.0/24"]
  zone           = "ru-central1-b"
  network_id     = "${yandex_vpc_network.main.id}"
  name = "public-b"
}

resource "yandex_vpc_subnet" "public-c" {
  v4_cidr_blocks = ["192.168.12.0/24"]
  zone           = "ru-central1-c"
  network_id     = "${yandex_vpc_network.main.id}"
  name = "public-c"
}