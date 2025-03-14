# Provider Kubernetes
provider "kubernetes" {
  host                   = jsondecode(var.kubeconfig)["host"]
  client_certificate     = base64decode(jsondecode(var.kubeconfig)["client_certificate"])
  client_key             = base64decode(jsondecode(var.kubeconfig)["client_key"])
  cluster_ca_certificate = base64decode(jsondecode(var.kubeconfig)["cluster_ca_certificate"])
}

# Provider Helm
provider "helm" {
  kubernetes {
    host                   = jsondecode(var.kubeconfig)["host"]
    client_certificate     = base64decode(jsondecode(var.kubeconfig)["client_certificate"])
    client_key             = base64decode(jsondecode(var.kubeconfig)["client_key"])
    cluster_ca_certificate = base64decode(jsondecode(var.kubeconfig)["cluster_ca_certificate"])
  }
}

# Install just the FluxCD components
resource "helm_release" "flux" {
  name       = "flux"
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"
  namespace  = "flux-system"
  create_namespace = true
  
  # Optional: Configure Flux via Helm values
  # values = [
  #   file("${path.module}/values.yaml")
  # ]
}

# Create the SSH secret for Flux
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