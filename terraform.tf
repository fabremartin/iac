terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.22.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.2.2"
    }
  }
}
