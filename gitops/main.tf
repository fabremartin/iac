provider "kubernetes" {
  config_path = "${path.module}/kubeconfig.yaml"
}

provider "helm" {
  kubernetes {
    config_path = "${path.module}/kubeconfig.yaml"
  }
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
    var.flux_helm_release,
    var.flux_git_auth_secret,
    var.aks_cluster
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
    kubernetes_manifest.flux_git_repository
  ]
}