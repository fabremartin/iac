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
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}
