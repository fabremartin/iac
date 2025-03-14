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

# GitOps: FluxCD
resource "helm_release" "flux" {
  name       = "flux"
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"
  namespace  = "flux-system"

  create_namespace = true

  depends_on = [
    var.aks_cluster,
    var.cluster_ready
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

  depends_on = [helm_release.flux, var.cluster_ready]
}

# Ressource GitRepository pour FluxCD // A jouer après avoir déployer l'infra + flux
resource "kubernetes_manifest" "flux_git_repository" {
  manifest = {
    apiVersion = "source.toolkit.fluxcd.io/v1beta1"
    kind       = "GitRepository"
    metadata = {
      name      = "flux-repo"
      namespace = "flux-system"
    }
    spec = {
      url       = var.gitops_repo_url
      secretRef = { name = "fluxcd-key" }
      interval  = "1m"
      ref = {
        branch = "main"
      }
    }
  }

  depends_on = [
    helm_release.flux,
    kubernetes_secret.flux_git_auth,
    var.aks_cluster,
    var.cluster_ready
  ]
}

resource "kubernetes_manifest" "flux_kustomization" {
  manifest = {
    apiVersion = "kustomize.toolkit.fluxcd.io/v1beta1"
    kind       = "Kustomization"
    metadata = {
      name      = "kustomization"
      namespace = "flux-system"
    }
    spec = {
      interval = "10m"
      path     = "."
      sourceRef = {
        kind = "GitRepository"
        name = "flux-repo"
      }
      targetNamespace = "default"
      prune = true
    }
  }

  depends_on = [
    kubernetes_manifest.flux_git_repository,
    var.cluster_ready
  ]
}