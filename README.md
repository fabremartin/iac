# Terraform AKS with FluxCD

This project sets up an Azure Kubernetes Service (AKS) cluster with FluxCD for GitOps-based deployment management and Azure Managed Grafana for monitoring and observability.

## Architecture

This solution follows a two-phased approach:

1. **Infrastructure Provisioning**: Using Terraform to create the AKS cluster, container registry, Azure Managed Grafana, and base FluxCD installation.
2. **GitOps Configuration**: Using FluxCD CLI in a CI/CD pipeline to configure the GitRepository and Kustomization resources.

## Gitops global architecture

![image](https://github.com/user-attachments/assets/415bcd12-1d03-4ce8-ad9e-86839cd98818)

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.0.0+)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (latest version)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) (latest version)
- [FluxCD CLI](https://fluxcd.io/docs/installation/) (latest version)
- An Azure subscription
- A Git repository for your kubernetes manifests

## Project Structure

```
.
├── .github/
│   └── workflows/
│       └── infra.yml     # GitHub Actions workflow for the Infra configuration
│       └── flux.yml      # GitHub Actions workflow for FluxCD configuration
├── gitops/
│   ├── kustomization.yaml          # Kustomization file to be applied
│   └── git-repository.yaml         # GitRepo file to be applied
├── main.tf                         # Main Terraform configuration
├── variables.tf                    # Variables for the main configuration
└── README.md                       # This file
```

## Variables

Currently, most variables are stored as GitHub secrets. A more secure and scalable approach would be to store them in Azure Key Vault in the future.

```hcl
resource_group_name = "aks-demo-rg"
location            = "eastus"
aks_cluster_name    = "aks-cluster"
kubernetes_version  = "1.30"
node_count          = 2
node_size           = "Standard_DS2_v2"
acr_name            = "myacrregistry"
sku                 = "Basic"
gitops_repo_url     = "ssh://git@github.com/yourusername/your-gitops-repo.git"
fluxcd_key          = "your-private-key"
fluxcd_key_pub      = "your-public-key"
known_hosts         = "known_hosts-content"
```

## Deployment Process

### 1. Infrastructure Deployment

To deploy the infrastructure:

```bash
# Initialize Terraform
terraform init

# Plan the deployment
terraform plan -out=tfplan

# Apply the deployment
terraform apply tfplan
```

This will create:
- Azure Resource Group
- AKS Cluster
- Azure Container Registry
- FluxCD installation in the AKS cluster

### 2. Configure FluxCD

After the infrastructure is deployed, configure FluxCD using the GitHub Actions workflow:

1. Store the following secrets in your GitHub repository secrets:
   - `KUBE_CONFIG`: The kubeconfig output from Terraform
   - `GIT_REPOSITORY_URL`: Your GitOps repository URL

2. Trigger the workflow manually from the GitHub Actions tab or set it up to run automatically after infrastructure deployment.

## GitOps Repository Structure

Your GitOps repository should follow a standard structure:

```
.
├── 
```

## Troubleshooting

Common issues and their solutions:

### FluxCD not detecting changes

Ensure that:
1. The SSH key has proper permissions to the repository
2. The branch name in the GitRepository resource matches your repository's default branch
3. The path in the Kustomization resource points to the correct directory

### AKS cluster connection issues

If you can't connect to the AKS cluster:
1. Ensure the kubeconfig is properly set up
2. Check if the AKS cluster has public network access enabled
3. Verify your Azure credentials are still valid

## Cleanup

To destroy the infrastructure:

```bash
terraform destroy
```

## Security Considerations & Potential Upgrades

- **Use Azure Key Vault** for secure storage of secrets and manage access via **Azure RBAC**.
- **System-assigned Managed Identity** for AKS enhances security by avoiding credentials management. Consider using **Azure AD** integration for tighter access control.
- Enable **Network Policies** and use **Private Endpoints** for services to restrict access to private networks.
- Store **Terraform state** in **Azure Blob Storage** for collaboration, state locking, and versioning.
- Automate **Grafana deployment** with Terraform and assign appropriate **Azure RBAC roles** for secure access.
- Set up a **full landing zone** with **VNET**, **IAM**, **Key Vault**, **NSGs**, and **Firewalls** for enhanced security.
- Follow **least privilege access** with **MFA** for privileged accounts and regularly audit permissions.
- Enable **Azure Monitor** and **Security Center** for threat detection and use **Azure Sentinel** for security incident management.
- Implement **backup and disaster recovery** plans to ensure business continuity.



## Links
- [iac repo](https://github.com/fabremartin/iac)
- [gitops repo](https://github.com/fabremartin/gitops)
- [json-server repo](https://github.com/fabremartin/json-server)
