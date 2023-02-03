terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
      bucket = "netology-vyushmanov-bucket"
      region = "eu-north-1"
      key = "terraform.tfstate"
      dynamodb_table = "terraform-state-lock"
    }
}

