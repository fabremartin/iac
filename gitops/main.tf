provider "helm" {
  kubernetes {
    host                   = var.kube_config_host
    cluster_ca_certificate = var.cluster_ca_certificate
    client_key             = var.client_key
    client_certificate     = var.client_certificate
  }
}

provider "kubernetes" {
  host                   = var.kube_config_host
  cluster_ca_certificate = var.cluster_ca_certificate
  client_key             = var.client_key
  client_certificate     = var.client_certificate
}



resource "helm_release" "flux" {
  name       = "flux"
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"
  namespace  = "flux-system"
  create_namespace = true

}

resource "kubernetes_secret" "flux_git_auth" {
  metadata {
    name      = "fluxcd-key"
    namespace = "flux-system"
  }

  type = "Opaque"
  data = {
    identity       = file("~/.ssh/fluxcd-key")
    "identity.pub" = file("~/.ssh/fluxcd-key.pub")
    known_hosts    = file("~/.ssh/known_hosts")
  }

  depends_on = [helm_release.flux]
}

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
    kubernetes_secret.flux_git_auth
  ]
}