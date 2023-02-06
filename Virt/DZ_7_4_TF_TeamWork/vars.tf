variable "region" {
  type = string
  default = "eu-north-1"
}

locals {
  instance_type = {
    stage = "t2.micro"
    prod = "t3.micro"
  }

  cores = {
    stage = 1
    prod = 2
  }

  cores_threads = {
    stage = 1
    prod = 2
  }

  ec2_count = {
    stage = 1
    prod = 2
  }

  res_count = {    
      netology_1core = 1
      netology_2core = 2
    }
}