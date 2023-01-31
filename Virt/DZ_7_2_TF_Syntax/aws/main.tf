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
  instance_type = "t3.micro"
  cpu_core_count = 1
  cpu_threads_per_core = 1
  root_block_device {
    volume_size = 15
    volume_type = "gp2"

  }

  tags = {
    Name = "netology_vyushmanov"
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}
