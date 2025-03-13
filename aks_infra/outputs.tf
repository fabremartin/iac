output "aks_kube_config" {
  value = azurerm_kubernetes_cluster.rg-test.kube_config
}
