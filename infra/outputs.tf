output "kube_config_host" {
  value = azurerm_kubernetes_cluster.rg-1.kube_config.0.host
  sensitive = true
}

output "kube_config_client_certificate" {
  value = azurerm_kubernetes_cluster.rg-1.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config_client_key" {
  value = azurerm_kubernetes_cluster.rg-1.kube_config.0.client_key
  sensitive = true
}

output "kube_config_cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.rg-1.kube_config.0.cluster_ca_certificate
  sensitive = true
}
