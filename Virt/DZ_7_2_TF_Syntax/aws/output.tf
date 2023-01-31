output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "caller_user" {
  value = data.aws_caller_identity.current.user_id
}

output "region" {
  value = data.aws_region.current.name
}

output "IP" {
  value = resource.aws_instance.netology.private_ip
}

output "subnet_id" {
  value = resource.aws_instance.netology.subnet_id
}
