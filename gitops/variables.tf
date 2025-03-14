variable "gitops_repo_url" {
  description = "Git repository URL for Flux CD"
  type        = string
  default     = "https://github.com/fabremartin/gitops"
}

variable "kubeconfig" {
  type      = string
  sensitive = true
}

variable "flux_helm_release" {
  description = "Helm release for FluxCD"
  type        = any
}

variable "flux_git_auth_secret" {
  description = "FluxCD Git authentication secret"
  type        = any
}

variable "aks_cluster" {
  description = "AKS Kubernetes Cluster"
  type        = any
}