data "terraform_remote_state" "infra" {
  backend = "azurerm"
  config = {
    resource_group_name  = "rg-terraform-backend"
    storage_account_name = "tfbackend62400"
    container_name       = "tfstate"
    key                  = "infra.terraform.tfstate"
  }
}


# Kubernetes provider
provider "kubernetes" {
  host                   = data.terraform_remote_state.infra.outputs.kube_config_host
  client_certificate     = base64decode(data.terraform_remote_state.infra.outputs.kube_config_client_certificate)
  client_key             = base64decode(data.terraform_remote_state.infra.outputs.kube_config_client_key)
  cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.kube_config_cluster_ca_certificate)
}

# Helm provider
provider "helm" {
  kubernetes = {
    host                   = data.terraform_remote_state.infra.outputs.kube_config_host
    client_certificate     = base64decode(data.terraform_remote_state.infra.outputs.kube_config_client_certificate)
    client_key             = base64decode(data.terraform_remote_state.infra.outputs.kube_config_client_key)
    cluster_ca_certificate = base64decode(data.terraform_remote_state.infra.outputs.kube_config_cluster_ca_certificate)
  }
}

# GitOps: FluxCD
resource "helm_release" "flux" {
  name             = "flux2"
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  version          = "2.12.0"
  namespace        = "flux-system"
  create_namespace = true
}

# Auth
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
