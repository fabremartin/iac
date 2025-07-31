# Azure provider
provider "azurerm" {
  features {
    /*resource_group {
      prevent_deletion_if_contains_resources = false
    }*/
  }
  #subscription_id = "for deletion purpose"
}

# ResourceGroup creation
resource "azurerm_resource_group" "rg-1" {
  name     = var.resource_group_name
  location = var.location
}

# AKS Cluster creation
resource "azurerm_kubernetes_cluster" "rg-1" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg-1.location
  resource_group_name = azurerm_resource_group.rg-1.name
  kubernetes_version  = var.kubernetes_version

  dns_prefix = "aks-demo-cluster"

  default_node_pool {
    name                 = "default"
    node_count           = var.node_count
    vm_size              = var.node_size
    auto_scaling_enabled = true
    min_count            = var.node_count
    max_count            = var.node_count
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
  resource_group_name = azurerm_resource_group.rg-1.name
  location            = azurerm_resource_group.rg-1.location
  sku                 = var.sku
  admin_enabled       = true
}

# Get the kubelet identity
data "azurerm_user_assigned_identity" "kubelet_identity" {
  name                = "${azurerm_kubernetes_cluster.rg-1.name}-agentpool"
  resource_group_name = azurerm_kubernetes_cluster.rg-1.node_resource_group
  depends_on = [
    azurerm_kubernetes_cluster.rg-1
  ]
}

# Link ACR to AKS
resource "azurerm_role_assignment" "aks_acr_binding" {
  principal_id         = data.azurerm_user_assigned_identity.kubelet_identity.principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
  depends_on = [
    azurerm_kubernetes_cluster.rg-1,
    azurerm_container_registry.acr
  ]
}

# Grafana creation - Skipping this for now
/*resource "azurerm_dashboard_grafana" "example" {
  name                = var.grafana_name
  grafana_major_version = 10
  resource_group_name = azurerm_resource_group.rg-1.name
  location            = azurerm_resource_group.rg-1.location

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production" //Not needed now
  }
}*/