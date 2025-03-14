variable "gitops_repo_url" {
  description = "Git repository URL for Flux CD"
  type        = string
  default     = "https://github.com/fabremartin/gitops"
}

variable "kubeconfig" {
  type      = string
  sensitive = true
}

variable "aks_cluster" {
  description = "AKS Kubernetes Cluster"
  type        = any
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
