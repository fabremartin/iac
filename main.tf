# Azure
provider "azurerm" {
  features {
    /*resource_group {
      prevent_deletion_if_contains_resources = false
    }*/
  }
  #subscription_id = "for deletion purpose"
}

# ResourceGroup creation
resource "azurerm_resource_group" "rg-test" {
  name     = var.resource_group_name
  location = var.location
}

# AKS Cluster creation
resource "azurerm_kubernetes_cluster" "rg-test" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg-test.location
  resource_group_name = azurerm_resource_group.rg-test.name
  kubernetes_version  = var.kubernetes_version

  dns_prefix = "aks-demo-cluster"

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_size
  }

  tags = {
    Environment = "Production"
  }

  identity {
    type = "SystemAssigned"
  }
}

# ACR
resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg-test.name
  location            = azurerm_resource_group.rg-test.location
  sku                 = var.sku
  admin_enabled       = true
}

# Link ACR to AKS
resource "azurerm_role_assignment" "aks_acr_binding" {
  principal_id         = azurerm_kubernetes_cluster.rg-test.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
  depends_on           = [azurerm_kubernetes_cluster.rg-test]
}

module "gitops" {
  source          = "./gitops"
  kubeconfig      = azurerm_kubernetes_cluster.rg-test.kube_config_raw
  gitops_repo_url = var.gitops_repo_url
  aks_cluster     = azurerm_kubernetes_cluster.rg-test
  fluxcd_key      = var.fluxcd_key
  fluxcd_key_pub  = var.fluxcd_key_pub
  known_hosts     = var.known_hosts
}

# Output: Display kubeconfig infos to connect
output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.rg-test.kube_config_raw
  sensitive = true
}

