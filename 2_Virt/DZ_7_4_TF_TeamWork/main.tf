provider "aws" {
  region = "eu-north-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "netology" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.instance_type[terraform.workspace]
  cpu_core_count = local.cores[terraform.workspace]
  cpu_threads_per_core = local.cores_threads[terraform.workspace]
  root_block_device {
    volume_size = 15
    volume_type = "gp2"

  }

  tags = {
    Name = format("%s.netology_test-%s", terraform.workspace, count.index+1)
  }
  count = local.ec2_count[terraform.workspace]
  lifecycle {
    create_before_destroy = true
  }
  
}

resource "aws_instance" "netology2" {
  for_each = local.res_count 
  
  ami           = data.aws_ami.ubuntu.id
  instance_type = local.instance_type[terraform.workspace]
  cpu_core_count = each.value
  cpu_threads_per_core = local.cores_threads[terraform.workspace]
  root_block_device {
    volume_size = 15
    volume_type = "gp2"

  }

  tags = {
    Name = each.key
  }
}


data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
