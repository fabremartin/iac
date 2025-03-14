variable "kubeconfig" {
  description = "Kubernetes config"
  type        = string
  sensitive   = true
}

variable "fluxcd_key" {
  description = "FluxCD private key"
  type        = string
  sensitive   = true
}

variable "fluxcd_key_pub" {
  description = "FluxCD public key"
  type        = string
}

variable "known_hosts" {
  description = "SSH known hosts"
  type        = string
}