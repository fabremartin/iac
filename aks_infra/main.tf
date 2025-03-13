resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location        
}

/*resource "azuread_application" "aks" {
  display_name = "aks-app"
}

resource "azuread_service_principal" "aks" {
  client_id = azuread_application.aks.client_id
}


resource "azurerm_role_assignment" "aks_role" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.aks.object_id
}*/

resource "azurerm_kubernetes_cluster" "rg-test" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = var.node_size
  }

  identity {
    type = "SystemAssigned"
  }

  dns_prefix = "aks-demo-cluster"

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.sku
  admin_enabled       = true
}

resource "azurerm_role_assignment" "aks_acr_binding" {
  principal_id         = azurerm_kubernetes_cluster.rg-test.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}
