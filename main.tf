# Azure
provider "azurerm" {
  features {
    /*resource_group {
      prevent_deletion_if_contains_resources = false
    }*/
  }
  #subscription_id = "for deletion purpose"
}

# Helm for GitOps
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.rg-1.kube_config.0.host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.rg-1.kube_config.0.client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.rg-1.kube_config.0.client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.rg-1.kube_config.0.cluster_ca_certificate)
  }
}

# Kubernetes provider for interacting with the cluster
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.rg-1.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.rg-1.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.rg-1.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.rg-1.kube_config.0.cluster_ca_certificate)
}

# ResourceGroup creation
resource "azurerm_resource_group" "rg-1" {
  name     = var.resource_group_name
  location = var.location
}

# Grafana creation
resource "azurerm_dashboard_grafana" "example" {
  name                = var.grafana_name
  grafana_major_version = 10
  resource_group_name = azurerm_resource_group.rg-1.name
  location            = azurerm_resource_group.rg-1.location

  identity {
    type = "SystemAssigned"
  }

  /*tags = {
    Environment = "Production" //Not needed now
  }*/
}


# AKS Cluster creation
resource "azurerm_kubernetes_cluster" "rg-1" {
  name                = var.aks_cluster_name
  location            = azurerm_resource_group.rg-1.location
  resource_group_name = azurerm_resource_group.rg-1.name
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
  resource_group_name = azurerm_resource_group.rg-1.name
  location            = azurerm_resource_group.rg-1.location
  sku                 = var.sku
  admin_enabled       = true
}

# Link ACR to AKS
resource "azurerm_role_assignment" "aks_acr_binding" {
  principal_id         = azurerm_kubernetes_cluster.rg-1.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
  depends_on           = [azurerm_kubernetes_cluster.rg-1]
}


# GitOps: FluxCD
resource "helm_release" "flux" {
  name       = "flux"
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"
  namespace  = "flux-system"

  create_namespace = true

  depends_on = [
    azurerm_kubernetes_cluster.rg-1
  ]
}

resource "kubernetes_secret" "flux_git_auth" {
  metadata {
    name      = "fluxcd-key"
    namespace = "flux-system"
  }

  type = "Opaque"
  data = {
    identity       = var.fluxcd_key
    "identity.pub" = var.fluxcd_key_pub
    known_hosts    = var.known_hosts
  }

  depends_on = [helm_release.flux]
}

# Output: Display kubeconfig infos to connect
output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.rg-1.kube_config_raw
  sensitive = true
}