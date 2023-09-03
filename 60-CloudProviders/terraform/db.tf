resource "yandex_mdb_mysql_cluster" "mysql-cluster" {
  name        = "test"
  environment = "PRESTABLE"
  network_id  = yandex_vpc_network.main.id
  version     = "8.0"

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.private.id
    priority = 100
  }

  host {
    zone      = "ru-central1-b"
    subnet_id = yandex_vpc_subnet.private2.id
  }

  host {
    zone      = "ru-central1-c"
    subnet_id = yandex_vpc_subnet.private3.id
  }

  resources {
    resource_preset_id = "b1.medium"
    disk_type_id       = "network-ssd"
    disk_size          = 20
  }

  maintenance_window {
    type = "ANYTIME"
  }

  backup_window_start {
    hours = 23
    minutes = 59
  }

  deletion_protection = true
  
}

resource "yandex_mdb_mysql_database" "netology-db" {
    cluster_id = yandex_mdb_mysql_cluster.mysql-cluster.id
    name = "netology_db"
}

resource "yandex_mdb_mysql_user" "the-user" {
    cluster_id = yandex_mdb_mysql_cluster.mysql-cluster.id
    name       = "user"
    password   = "netology"

    permission {
      database_name = yandex_mdb_mysql_database.netology-db.name
      roles         = ["ALL"]
    }

    connection_limits {
      max_questions_per_hour   = 1000
      max_updates_per_hour     = 200
      max_connections_per_hour = 300
      max_user_connections     = 400
    }

    authentication_plugin = "MYSQL_NATIVE_PASSWORD"
}

output "fqdn" {
  value = yandex_mdb_mysql_cluster.mysql-cluster.host.*.fqdn[0]
}
  
