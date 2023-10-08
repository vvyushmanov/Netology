locals {
  folder_id = "b1gen0ivt5de5o1t09r6"
}

terraform {
  
  cloud {
    organization = "vyushmanov"

      workspaces {
      name = "Stage"
    }
  }
}