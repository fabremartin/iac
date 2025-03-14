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
    var.aks_cluster
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

  depends_on = [helm_release.flux]
}

# Use null_resource instead of kubernetes_manifest
resource "null_resource" "flux_git_setup" {
  triggers = {
    kubeconfig_changed = md5(var.kubeconfig)
    git_repo_url       = var.gitops_repo_url
  }

  provisioner "local-exec" {
    command = <<-EOT
      # Create a temporary kubeconfig file
      echo '${var.kubeconfig}' > kubeconfig.tmp
      
      # Wait for flux to be ready
      kubectl --kubeconfig=kubeconfig.tmp wait --for=condition=available --timeout=120s -n flux-system deployment/helm-controller deployment/source-controller deployment/kustomize-controller || true
      sleep 20  # Extra safety delay
      
      # Create GitRepository manifest as YAML
      cat > git-repository.yaml <<EOF
      apiVersion: source.toolkit.fluxcd.io/v1beta1
      kind: GitRepository
      metadata:
        name: flux-repo
        namespace: flux-system
      spec:
        url: ${var.gitops_repo_url}
        secretRef:
          name: fluxcd-key
        interval: 1m
        ref:
          branch: main
      EOF
      
      # Create Kustomization manifest as YAML
      cat > kustomization.yaml <<EOF
      apiVersion: kustomize.toolkit.fluxcd.io/v1beta1
      kind: Kustomization
      metadata:
        name: kustomization
        namespace: flux-system
      spec:
        interval: 10m
        path: .
        sourceRef:
          kind: GitRepository
          name: flux-repo
        targetNamespace: default
        prune: true
      EOF
      
      # Apply the manifests
      kubectl --kubeconfig=kubeconfig.tmp apply -f git-repository.yaml
      kubectl --kubeconfig=kubeconfig.tmp apply -f kustomization.yaml
      
      # Cleanup
      rm kubeconfig.tmp git-repository.yaml kustomization.yaml
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [
    kubernetes_secret.flux_git_auth,
    var.aks_cluster
  ]
}