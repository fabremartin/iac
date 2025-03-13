variable "kubernetes_version" {
  type = string
}

variable "aks_cluster_name" {
  type = string
}

variable "node_count" {
  type = number
}

variable "node_size" {
  type = string
}

variable "acr_name" {
  type = string
}

variable "sku" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}