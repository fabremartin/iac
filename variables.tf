

variable "resource_group_name" {
  default = "rg-1"
}

variable "aks_cluster_name" {
  default = "cluster-aks"
}

variable "location" {
  default = "East US"
}

variable "node_count" {
  default = 2
}

variable "node_size" {
  default = "Standard_DS2_v2"
}

variable "kubernetes_version" {
  description = "Kubernetes version for AKS cluster"
  default     = "1.30"
}

variable "acr_name" {
  description = "Azure Container Registry Name"
  type        = string
  default     = "regsitry14032025"
}

variable "sku" {
  description = "ACR SKU (Basic, Standard, Premium)"
  type        = string
  default     = "Basic"
}

variable "fluxcd_key" {
  type      = string
  sensitive = true
}

variable "fluxcd_key_pub" {
  type      = string
  sensitive = true
}

variable "known_hosts" {
  type      = string
  sensitive = true
}

variable "grafana_name" {
  type    = string
  default = "grafana-1"
}