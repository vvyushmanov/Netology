locals {
    node1-ip = data.yandex_compute_instance_group.my_group.instances.*.network_interface.0.ip_address[0]
    node1-nat-ip = data.yandex_compute_instance_group.my_group.instances.*.network_interface.0.nat_ip_address[0]
    node2-ip = data.yandex_compute_instance_group.my_group.instances.*.network_interface.0.ip_address[1]
    node2-nat-ip = data.yandex_compute_instance_group.my_group.instances.*.network_interface.0.nat_ip_address[1]
    node3-ip = data.yandex_compute_instance_group.my_group.instances.*.network_interface.0.ip_address[2]
    node3-nat-ip = data.yandex_compute_instance_group.my_group.instances.*.network_interface.0.nat_ip_address[2]
    lb-ip = yandex_lb_network_load_balancer.k8s-cplane.listener.*.external_address_spec[0].*.address[0]
}

resource "local_file" "inventory" {
  filename = "hosts.yml"
  content = templatefile("hosts.yml.tftpl",
    {
        node1-nat-ip = local.node1-nat-ip,
        node1-local-ip = local.node1-ip,
        node2-nat-ip = local.node2-nat-ip,
        node2-local-ip = local.node2-ip,
        node3-nat-ip = local.node3-nat-ip,
        node3-local-ip = local.node3-ip,
        lb-ip = local.lb-ip
    }
  )
}

output "k8s-apiserver" {
  value = local.lb-ip
}

output "main-ip" {
  value = yandex_alb_load_balancer.k8s-l7-balancer.listener.*.endpoint[0].*.address[0].*.external_ipv4_address[0].*.address[0]
}


data "yandex_compute_instance_group" "my_group" {
  instance_group_id = yandex_compute_instance_group.k8s-ig.id
}

output "instance_external_ip" {
  value = "${data.yandex_compute_instance_group.my_group.instances.*.network_interface.0.ip_address}"
}

output "instance_internal_ip" {
  value = "${data.yandex_compute_instance_group.my_group.instances.*.network_interface.0.nat_ip_address}"
}