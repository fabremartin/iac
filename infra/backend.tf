terraform {
  backend "azurerm" {
    resource_group_name  = "rg-1"
    storage_account_name = "tfbackend62400"
    container_name       = "tfstate"
    key                  = "infra.terraform.tfstate"
  }
}