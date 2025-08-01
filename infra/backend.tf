terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-backend"
    storage_account_name = "tfbackend62400"
    container_name       = "tfstate"
    key                  = "infra.terraform.tfstate"
  }
}