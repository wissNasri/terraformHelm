
terraform {
  # 1. Déclaration des providers requis par ce projet.
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.17"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.37.1"
    }
  }

# Configure le provider AWS pour utiliser la région définie dans les variables
provider "aws" {
  region = var.aws_region
}

# Configure le provider Helm pour utiliser le kubeconfig généré par `aws eks update-kubeconfig`
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

# Configure le provider Kubernetes (utile pour d'autres ressources k8s si besoin)
provider "kubernetes" {
  config_path = "~/.kube/config"
}
