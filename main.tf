provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  location            = var.location
}

module "landing_zone" {
  source              = "./landing_zone"
  resource_group_name = var.resource_group_name
  location            = var.location
}

module "aks_infra" {
  source              = "./aks_infra"
  sku                 = var.sku
  node_count          = var.node_count
  node_size           = var.node_size
  acr_name            = var.acr_name
  kubernetes_version  = var.kubernetes_version
  aks_cluster_name    = var.aks_cluster_name
  resource_group_name = var.resource_group_name
  location            = var.location
  #depends_on = [ module.landing_zone ]
}

module gitops {
  source          = "./gitops"
  gitops_repo_url = var.gitops_repo_url
  # Pass Kubernetes config outputs from aks_infra to gitops module
  kube_config_host       = module.aks_infra.aks_kube_config[0].host
  cluster_ca_certificate = module.aks_infra.aks_kube_config[0].cluster_ca_certificate
  client_key             = module.aks_infra.aks_kube_config[0].client_key
  client_certificate     = module.aks_infra.aks_kube_config[0].client_certificate
  #depends_on = [ module.landing_zone, module.aks_infra ]
}

