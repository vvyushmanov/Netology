provider "yandex" {
    // все параметры заданы через export YC_*
}

data "yandex_compute_image" "Ubuntu-22" {
  family = "ubuntu-2204-lts"
}

resource "yandex_compute_instance" "Netology-Ubuntu-22" {
  name = "netologyvyushmanov"
  hostname = "vyushmanov"

  boot_disk {
    initialize_params {
      image_id = "${data.yandex_compute_image.Ubuntu-22.id}"
      size = 15
    }
  }
  network_interface {   
    subnet_id = "e9b20c9j4u08daq9vf8e" 
  }

  resources {
    cores = 2
    memory = 2
  }
}
